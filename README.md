# UsewiseSwift

Official Swift SDK for [Usewise](https://usewise.io) product analytics.

## Installation

### Swift Package Manager

Add to your `Package.swift` or in Xcode: File → Add Package Dependencies:

```
https://github.com/smasoftware/usewise-swift
```

## Quick Start

```swift
import UsewiseSwift

// Initialize in AppDelegate or App init
Usewise.initialize(config: UsewiseConfig(
    apiKey: "uw_live_your_api_key_here",
    baseUrl: "https://api.usewise.io/api/v1"
))

// Track events
Usewise.shared?.track("app_opened")
Usewise.shared?.track("button_click", properties: [
    "button": "signup",
    "page": "home"
])

// Identify after login
await Usewise.shared?.identify("user@example.com", traits: [
    "name": "Jane Smith",
    "plan": "pro"
])

// Process tracking
let processId = await Usewise.shared?.startProcess("checkout")
if let pid = processId {
    await Usewise.shared?.processStep(pid, stepName: "cart_review")
    await Usewise.shared?.processStep(pid, stepName: "payment")
    await Usewise.shared?.completeProcess(pid)
}

// Logout
Usewise.shared?.reset()

// Privacy
Usewise.shared?.optOut()
Usewise.shared?.optIn()
```

## Features

- Event tracking with auto-batching
- User identification (anonymous + authenticated)
- Process/funnel tracking
- Device context auto-capture (OS, model, app version, VPN, jailbreak)
- Screen size capture
- Retry with exponential backoff
- Opt-out/opt-in support
- UserDefaults persistence for anonymous ID

## Platforms

- iOS 15+
- macOS 12+
