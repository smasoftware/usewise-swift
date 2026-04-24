import Foundation

public final class Usewise {
    public static var shared: Usewise?

    private let config: UsewiseConfig
    private let httpClient: HttpClient
    private let eventQueue: EventQueue
    private let storage: UsewiseStorage
    private let deviceContext: DeviceContext
    private var anonymousId: String
    private var userId: String?
    private var optedOut: Bool

    private init(config: UsewiseConfig) {
        self.config = config
        self.storage = UsewiseStorage()
        self.httpClient = HttpClient(config: config)
        self.eventQueue = EventQueue(httpClient: httpClient, config: config)
        self.deviceContext = DeviceContext.capture()

        // Load or generate anonymous ID
        if let stored = storage.getString("anonymous_id") {
            self.anonymousId = stored
        } else {
            self.anonymousId = UUID().uuidString.lowercased()
            storage.setString("anonymous_id", anonymousId)
        }

        // Load opt-out state
        self.optedOut = storage.getBool("opted_out")

        eventQueue.start()
    }

    // MARK: - Initialize

    public static func initialize(config: UsewiseConfig) {
        shared = Usewise(config: config)
    }

    // MARK: - Track

    public func track(
        _ event: String,
        properties: [String: Any]? = nil,
        element: ElementData? = nil,
        page: PageData? = nil
    ) {
        guard !optedOut else { return }

        var screenData: ScreenData? = nil
        if let w = deviceContext.screenWidth, let h = deviceContext.screenHeight {
            screenData = ScreenData(width: w, height: h)
        }

        let trackEvent = TrackEvent(
            event: event,
            anonymous_id: anonymousId,
            user_id: userId,
            event_uuid: UUID().uuidString.lowercased(),
            timestamp: ISO8601DateFormatter().string(from: Date()),
            properties: properties?.mapValues { AnyCodable($0) },
            element: element,
            page: page,
            screen: screenData,
            context: DeviceContextData(
                device_os: deviceContext.deviceOS,
                device_model: deviceContext.deviceModel,
                app_version: deviceContext.appVersion,
                is_vpn: deviceContext.isVpn,
                is_jailbroken: deviceContext.isJailbroken
            )
        )

        eventQueue.add(trackEvent)
    }

    // MARK: - Identify

    public func identify(_ userId: String, traits: [String: Any]? = nil) async {
        guard !optedOut else { return }

        await eventQueue.flush()
        self.userId = userId

        let payload = IdentifyPayload(
            anonymous_id: anonymousId,
            user_id: userId,
            traits: traits?.mapValues { AnyCodable($0) }
        )

        do {
            _ = try await httpClient.post("/identify", body: payload)
        } catch {
            if config.enableLogging {
                print("[Usewise] Identify failed: \(error)")
            }
        }
    }

    // MARK: - Process Tracking

    public func startProcess(_ name: String, properties: [String: Any]? = nil) async -> String? {
        guard !optedOut else { return nil }

        let payload = ProcessStartPayload(
            process_name: name,
            anonymous_id: anonymousId,
            user_id: userId,
            properties: properties?.mapValues { AnyCodable($0) }
        )

        do {
            let data = try await httpClient.post("/process/start", body: payload)
            let response = try JSONDecoder().decode(ProcessStartResponse.self, from: data)
            return response.process_id
        } catch {
            if config.enableLogging {
                print("[Usewise] startProcess failed: \(error)")
            }
            return nil
        }
    }

    public func processStep(_ processId: String, stepName: String, properties: [String: Any]? = nil) async {
        guard !optedOut else { return }

        let payload = ProcessStepPayload(
            process_id: processId,
            step_name: stepName,
            properties: properties?.mapValues { AnyCodable($0) }
        )

        do {
            _ = try await httpClient.post("/process/step", body: payload)
        } catch {
            if config.enableLogging {
                print("[Usewise] processStep failed: \(error)")
            }
        }
    }

    public func completeProcess(_ processId: String) async {
        guard !optedOut else { return }

        do {
            _ = try await httpClient.post("/process/complete", body: ProcessCompletePayload(process_id: processId))
        } catch {
            if config.enableLogging {
                print("[Usewise] completeProcess failed: \(error)")
            }
        }
    }

    public func failProcess(_ processId: String, reason: String? = nil) async {
        guard !optedOut else { return }

        do {
            _ = try await httpClient.post("/process/fail", body: ProcessFailPayload(process_id: processId, reason: reason))
        } catch {
            if config.enableLogging {
                print("[Usewise] failProcess failed: \(error)")
            }
        }
    }

    // MARK: - Flush / Reset / Privacy

    public func flush() async {
        guard !optedOut else { return }
        await eventQueue.flush()
    }

    public func reset() {
        userId = nil
        anonymousId = UUID().uuidString.lowercased()
        storage.setString("anonymous_id", anonymousId)
        eventQueue.clear()
    }

    public func optOut() {
        optedOut = true
        storage.setBool("opted_out", true)
        eventQueue.clear()
    }

    public func optIn() {
        optedOut = false
        storage.setBool("opted_out", false)
    }

    public func shutdown() async {
        await flush()
        eventQueue.dispose()
        Usewise.shared = nil
    }

    // MARK: - Getters

    public var currentAnonymousId: String { anonymousId }
    public var currentUserId: String? { userId }
    public var isOptedOut: Bool { optedOut }
}
