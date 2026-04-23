import Foundation

final class UsewiseStorage {
    private let defaults = UserDefaults.standard
    private let prefix = "usewise_"

    func getString(_ key: String) -> String? {
        defaults.string(forKey: prefix + key)
    }

    func setString(_ key: String, _ value: String) {
        defaults.set(value, forKey: prefix + key)
    }

    func getBool(_ key: String) -> Bool {
        defaults.bool(forKey: prefix + key)
    }

    func setBool(_ key: String, _ value: Bool) {
        defaults.set(value, forKey: prefix + key)
    }

    func remove(_ key: String) {
        defaults.removeObject(forKey: prefix + key)
    }
}
