import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

struct DeviceContext {
    let deviceOS: String
    let deviceModel: String
    let appVersion: String
    let isVpn: Bool
    let isJailbroken: Bool
    let screenWidth: Int?
    let screenHeight: Int?

    static func capture() -> DeviceContext {
        #if os(iOS)
        let os = "ios"
        let model = deviceModelIdentifier()
        let screen = UIScreen.main.bounds
        let screenW = Int(screen.width)
        let screenH = Int(screen.height)
        #elseif os(macOS)
        let os = "macos"
        let model = macModelIdentifier()
        let screen = NSScreen.main?.frame ?? .zero
        let screenW = Int(screen.width)
        let screenH = Int(screen.height)
        #else
        let os = "unknown"
        let model = "unknown"
        let screenW: Int? = nil
        let screenH: Int? = nil
        #endif

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

        return DeviceContext(
            deviceOS: os,
            deviceModel: model,
            appVersion: version,
            isVpn: checkVpn(),
            isJailbroken: checkJailbreak(),
            screenWidth: screenW,
            screenHeight: screenH
        )
    }

    private static func deviceModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        return mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }

    #if os(macOS)
    private static func macModelIdentifier() -> String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }
    #endif

    private static func checkVpn() -> Bool {
        guard let cfDict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
              let scoped = cfDict["__SCOPED__"] as? [String: Any] else {
            return false
        }
        let vpnKeys = ["tap", "tun", "ppp", "ipsec", "utun"]
        return scoped.keys.contains { key in
            vpnKeys.contains { key.lowercased().contains($0) }
        }
    }

    private static func checkJailbreak() -> Bool {
        #if os(iOS) && !targetEnvironment(simulator)
        let paths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
        ]
        return paths.contains { FileManager.default.fileExists(atPath: $0) }
        #else
        return false
        #endif
    }
}
