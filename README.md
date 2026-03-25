# urlhook

Execute [x-callback-urls](http://x-callback-url.com/) from the command line on macOS.

## Install

```
npm install -g urlhook
```

## Usage

```bash
urlhook "bear://x-callback-url/tags?token=YOUR_TOKEN"
urlhook "bear://x-callback-url/open-note?title=My%20Note" --timeout 20
```

## Options

```
urlhook <url> [options]

--timeout, -t    Timeout in seconds (default: 10)
--help, -h       Show help
--version, -v    Show version
```

## Response

Success (stdout, exit 0):
```json
{"success": true, "params": {"tags": "cooking,recipes"}}
```

Error (stderr, exit 1):
```json
{"success": false, "params": {"errorCode": "-1", "errorMessage": "Not found"}}
```

## Build from Source

Requires Xcode Command Line Tools.

```bash
git clone https://github.com/360ammar/cback.git
cd cback
make build
```

The app bundle is built to `macos/urlhook.app/`. Run directly with `./bin/urlhook`.

## How it Works

urlhook registers a `urlhook://` URL scheme via a background macOS app bundle. When you call an x-callback-url, urlhook injects its own callback URLs, launches the target app, and waits for the response over a Unix domain socket.

Each invocation is isolated — concurrent calls are safe.

## Requirements

- macOS 13 (Ventura) or later

## License

MIT
