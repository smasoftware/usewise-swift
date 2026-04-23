import Foundation

enum UsewiseError: Error {
    case networkError(Error)
    case apiError(statusCode: Int, message: String)
    case notInitialized
}

final class HttpClient {
    private let baseUrl: String
    private let apiKey: String
    private let timeout: TimeInterval
    private let maxRetries: Int
    private let enableLogging: Bool
    private let session: URLSession

    init(config: UsewiseConfig) {
        self.baseUrl = config.baseUrl
        self.apiKey = config.apiKey
        self.timeout = config.httpTimeout
        self.maxRetries = config.maxRetries
        self.enableLogging = config.enableLogging

        let urlConfig = URLSessionConfiguration.default
        urlConfig.timeoutIntervalForRequest = config.httpTimeout
        self.session = URLSession(configuration: urlConfig)
    }

    func post<T: Encodable>(_ path: String, body: T) async throws -> Data {
        let url = URL(string: "\(baseUrl)\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.httpBody = try JSONEncoder().encode(body)

        var lastError: Error?

        for attempt in 0...maxRetries {
            do {
                let (data, response) = try await session.data(for: request)
                let httpResponse = response as! HTTPURLResponse

                if (200..<300).contains(httpResponse.statusCode) {
                    return data
                }

                // 4xx — don't retry (except 429)
                if (400..<500).contains(httpResponse.statusCode) && httpResponse.statusCode != 429 {
                    let message = String(data: data, encoding: .utf8) ?? "Client error"
                    throw UsewiseError.apiError(statusCode: httpResponse.statusCode, message: message)
                }

                // 429 or 5xx — retry
                if attempt < maxRetries {
                    let delay = min(pow(2.0, Double(attempt)), 30) + Double.random(in: 0...0.5)
                    if enableLogging {
                        print("[Usewise] Retry \(attempt) after \(delay)s (status: \(httpResponse.statusCode))")
                    }
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }

                throw UsewiseError.apiError(statusCode: httpResponse.statusCode, message: "Server error after retries")
            } catch let error as UsewiseError {
                throw error
            } catch {
                lastError = error
                if attempt < maxRetries {
                    let delay = min(pow(2.0, Double(attempt)), 30)
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }

        throw UsewiseError.networkError(lastError ?? NSError(domain: "Usewise", code: -1))
    }
}
