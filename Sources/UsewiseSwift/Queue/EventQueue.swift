import Foundation

final class EventQueue {
    private var queue: [TrackEvent] = []
    private let lock = NSLock()
    private let httpClient: HttpClient
    private let flushAt: Int
    private let maxQueueSize: Int
    private let flushInterval: TimeInterval
    private let enableLogging: Bool
    private var timer: Timer?
    private var isFlushing = false

    init(httpClient: HttpClient, config: UsewiseConfig) {
        self.httpClient = httpClient
        self.flushAt = config.flushAt
        self.maxQueueSize = config.maxQueueSize
        self.flushInterval = config.flushIntervalSeconds
        self.enableLogging = config.enableLogging
    }

    func start() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.timer = Timer.scheduledTimer(withTimeInterval: self.flushInterval, repeats: true) { [weak self] _ in
                Task { await self?.flush() }
            }
        }
    }

    func add(_ event: TrackEvent) {
        lock.lock()
        queue.append(event)
        while queue.count > maxQueueSize {
            queue.removeFirst()
        }
        let shouldFlush = queue.count >= flushAt
        lock.unlock()

        if shouldFlush {
            Task { await flush() }
        }
    }

    func flush() async {
        lock.lock()
        guard !isFlushing, !queue.isEmpty else {
            lock.unlock()
            return
        }
        isFlushing = true
        let batchSize = min(queue.count, 100)
        let batch = Array(queue.prefix(batchSize))
        lock.unlock()

        do {
            _ = try await httpClient.post("/batch", body: BatchPayload(batch: batch))
            lock.lock()
            queue.removeFirst(batchSize)
            lock.unlock()
        } catch {
            if enableLogging {
                print("[Usewise] Flush failed: \(error)")
            }
        }

        lock.lock()
        isFlushing = false
        let hasMore = !queue.isEmpty
        lock.unlock()

        if hasMore {
            await flush()
        }
    }

    func clear() {
        lock.lock()
        queue.removeAll()
        lock.unlock()
    }

    func dispose() {
        timer?.invalidate()
        timer = nil
    }
}
