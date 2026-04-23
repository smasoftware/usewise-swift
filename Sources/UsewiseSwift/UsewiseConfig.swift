import Foundation

public struct UsewiseConfig {
    public let apiKey: String
    public let baseUrl: String
    public let flushIntervalSeconds: TimeInterval
    public let flushAt: Int
    public let maxQueueSize: Int
    public let maxRetries: Int
    public let httpTimeout: TimeInterval
    public let enableLogging: Bool

    public init(
        apiKey: String,
        baseUrl: String = "https://api.usewise.io/api/v1",
        flushIntervalSeconds: TimeInterval = 30,
        flushAt: Int = 20,
        maxQueueSize: Int = 1000,
        maxRetries: Int = 3,
        httpTimeout: TimeInterval = 10,
        enableLogging: Bool = false
    ) {
        self.apiKey = apiKey
        self.baseUrl = baseUrl
        self.flushIntervalSeconds = flushIntervalSeconds
        self.flushAt = flushAt
        self.maxQueueSize = maxQueueSize
        self.maxRetries = maxRetries
        self.httpTimeout = httpTimeout
        self.enableLogging = enableLogging
    }
}
