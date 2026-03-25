import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var socketPath: String?
    private var expectedUUID: String?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let args = CommandLine.arguments
        // args[0] is the binary path, args[1] is the URL, args[2] is the socket path
        guard args.count >= 3 else {
            sendError(code: "invalid_args", message: "Usage: urlhook <url> <socket_path>")
            return
        }

        let urlString = args[1]
        socketPath = args[2]

        // Extract UUID from the URL's x-success param: urlhook://success/<uuid>
        if let url = URL(string: urlString),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let xSuccess = components.queryItems?.first(where: { $0.name == "x-success" })?.value,
           let successURL = URL(string: xSuccess) {
            expectedUUID = successURL.pathComponents.last
        }

        guard let url = URL(string: urlString) else {
            sendError(code: "invalid_url", message: "Invalid URL: \(urlString)")
            return
        }

        let success = NSWorkspace.shared.open(url)
        if !success {
            sendError(code: "open_failed", message: "Failed to open URL")
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        // Filter by UUID — ignore callbacks for other instances
        let pathUUID = url.pathComponents.last
        if let expected = expectedUUID, pathUUID != expected {
            return
        }

        // Determine success/error/cancel from host
        let host = url.host ?? ""
        let isSuccess = (host == "success")

        // Parse query params into flat dictionary
        var params: [String: String] = [:]
        for item in components.queryItems ?? [] {
            if let value = item.value {
                params[item.name] = value
            }
        }

        if !isSuccess {
            // For cancel, set error code if not present
            if host == "cancel" && params["errorCode"] == nil {
                params["errorCode"] = "cancel"
                params["errorMessage"] = params["errorMessage"] ?? "User cancelled"
            }
        }

        let response: [String: Any] = [
            "success": isSuccess,
            "params": params
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: response),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            sendToSocket(jsonString)
        }

        NSApplication.shared.terminate(nil)
    }

    private func sendError(code: String, message: String) {
        let response: [String: Any] = [
            "success": false,
            "params": ["errorCode": code, "errorMessage": message]
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: response),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            sendToSocket(jsonString)
        }
        NSApplication.shared.terminate(nil)
    }

    private func sendToSocket(_ message: String) {
        guard let path = socketPath else { return }
        let client = SocketClient(path: path)
        try? client.send(message)
    }
}
