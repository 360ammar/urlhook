---
name: urlhook
description: >
  Use when interacting with macOS apps via x-callback-url protocol from the
  command line. Triggers: querying Bear notes, triggering Shortcuts, controlling
  apps that support x-callback-url (Bear, Drafts, OmniFocus, Things, Ulysses,
  Shortcuts, etc.), or when the user wants to send a command to a macOS app and
  get a structured response back. macOS only.
compatibility: Requires macOS 13+. Install with npm install -g urlhook.
---

# urlhook

Execute [x-callback-urls](http://x-callback-url.com/) from the command line on macOS and get structured JSON responses.

## When to use

- User wants to interact with a macOS app that supports x-callback-url
- Querying or creating content in apps like Bear, Drafts, OmniFocus, Things, Ulysses
- Running Apple Shortcuts from the terminal
- Any task requiring a round-trip command to a macOS app with a response

## Install

```bash
npm install -g urlhook
```

## Usage

```bash
urlhook "<x-callback-url>" [--timeout <seconds>]
```

urlhook automatically injects `x-success`, `x-error`, and `x-cancel` callbacks — do NOT include them in the URL.

## Options

| Flag | Default | Description |
|------|---------|-------------|
| `--timeout, -t` | 10 | Timeout in seconds |
| `--help, -h` | | Show help |
| `--version, -v` | | Show version |

## Response format

**Success** (stdout, exit 0):
```json
{"success": true, "params": {"key": "value"}}
```

**Error** (stderr, exit 1):
```json
{"success": false, "params": {"errorCode": "-1", "errorMessage": "Not found"}}
```

**Timeout** (stderr, exit 1):
```json
{"success": false, "params": {"errorCode": "timeout", "errorMessage": "Timed out after 10s"}}
```

Parse with `jq`:
```bash
urlhook "bear://x-callback-url/open-tag?name=recipes&token=TOKEN" | jq '.params'
```

## Examples

### Bear

```bash
# List tags
urlhook "bear://x-callback-url/tags?token=YOUR_TOKEN"

# Search notes
urlhook "bear://x-callback-url/search?term=recipe&token=YOUR_TOKEN"

# Open a note by title
urlhook "bear://x-callback-url/open-note?title=Shopping%20List&token=YOUR_TOKEN"

# Create a note
urlhook "bear://x-callback-url/create?title=New%20Note&text=Hello&token=YOUR_TOKEN"
```

### Shortcuts

```bash
# Run a shortcut
urlhook "shortcuts://x-callback-url/run-shortcut?name=My%20Shortcut"

# Run with input
urlhook "shortcuts://x-callback-url/run-shortcut?name=My%20Shortcut&input=text&text=hello"
```

### Things 3

```bash
# Add a todo
urlhook "things://x-callback-url/add?title=Buy%20groceries&list=Shopping"
```

### Drafts

```bash
# Create a draft
urlhook "drafts://x-callback-url/create?text=Hello%20World"
```

## Gotchas

- **URL-encode parameters.** Spaces must be `%20`, special characters must be percent-encoded. Use `python3 -c "import urllib.parse; print(urllib.parse.quote('my string'))"` if needed.
- **Do NOT add x-success/x-error/x-cancel.** urlhook injects these automatically. Adding your own will break the response flow.
- **Increase timeout for slow operations.** Some apps take time to process. Use `--timeout 30` or higher for heavy operations.
- **Concurrent calls are safe.** Each invocation is isolated via UUID — multiple urlhook calls can run simultaneously.
- **App must be installed.** If the target app isn't installed, the URL will fail to open.
- **Token-based apps.** Bear and some other apps require an API token. The user must provide this — do not guess or fabricate tokens.
- **Exit codes matter.** Exit 0 = success, exit 1 = error. Use `$?` or conditional execution (`&&` / `||`) to handle results.
