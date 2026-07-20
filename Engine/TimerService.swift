import Foundation

/// Injectable time source for deterministic timer tests (P4.6).
protocol Clock {
    var now: TimeInterval { get }
}

/// Monotonic uptime clock — does not jump with wall-clock changes.
struct SystemClock: Clock {
    var now: TimeInterval { ProcessInfo.processInfo.systemUptime }
}

/// Tracks puzzle elapsed time with pause / resume / stop / reset.
///
/// Source of truth for display is synced into `GameSession.elapsedSeconds` by the view model.
final class TimerService {
    private(set) var elapsedSeconds: Int = 0

    private let clock: Clock
    private var accumulated: TimeInterval = 0
    private var segmentStart: TimeInterval?
    private var isRunning = false
    private var isStopped = false

    init(clock: Clock = SystemClock()) {
        self.clock = clock
    }

    /// Begins counting if idle and not stopped (idempotent while running).
    func start() {
        guard !isStopped else { return }
        guard !isRunning else { return }
        isRunning = true
        segmentStart = clock.now
    }

    /// Freezes accumulation (app background). Safe to call when already paused.
    func pause() {
        guard isRunning else { return }
        flush()
        isRunning = false
    }

    /// Continues after pause if not stopped.
    func resume() {
        guard !isStopped else { return }
        guard !isRunning else { return }
        isRunning = true
        segmentStart = clock.now
    }

    /// Freezes the final time (puzzle complete). No further accumulation.
    func stop() {
        if isRunning {
            flush()
        }
        isRunning = false
        isStopped = true
        segmentStart = nil
    }

    /// Clears all state back to zero for a new attempt.
    func reset() {
        elapsedSeconds = 0
        accumulated = 0
        segmentStart = nil
        isRunning = false
        isStopped = false
    }

    /// Restores a previously persisted elapsed time (P4.7).
    func restore(elapsedSeconds: Int, completed: Bool) {
        reset()
        let clamped = max(0, elapsedSeconds)
        self.elapsedSeconds = clamped
        accumulated = TimeInterval(clamped)
        if completed {
            isStopped = true
        }
    }

    /// Refreshes `elapsedSeconds` from the clock while running.
    func tick() {
        guard isRunning, let start = segmentStart else { return }
        elapsedSeconds = Int(accumulated + (clock.now - start))
    }

    private func flush() {
        guard let start = segmentStart else { return }
        accumulated += clock.now - start
        elapsedSeconds = Int(accumulated)
        segmentStart = nil
    }
}

// MARK: - Formatting

enum ElapsedTimeFormatting {
    /// mm:ss display (AC-5).
    static func display(seconds: Int) -> String {
        let clamped = max(0, seconds)
        let minutes = clamped / 60
        let secs = clamped % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    /// VoiceOver-friendly label, e.g. "2 minutes 5 seconds".
    static func accessibilityLabel(seconds: Int) -> String {
        let clamped = max(0, seconds)
        let minutes = clamped / 60
        let secs = clamped % 60

        let minutePart: String
        switch minutes {
        case 0: minutePart = ""
        case 1: minutePart = "1 minute"
        default: minutePart = "\(minutes) minutes"
        }

        let secondPart: String
        switch secs {
        case 0 where minutes == 0: secondPart = "0 seconds"
        case 0: secondPart = ""
        case 1: secondPart = "1 second"
        default: secondPart = "\(secs) seconds"
        }

        switch (minutePart.isEmpty, secondPart.isEmpty) {
        case (true, true):
            return "0 seconds"
        case (false, true):
            return minutePart
        case (true, false):
            return secondPart
        case (false, false):
            return "\(minutePart) \(secondPart)"
        }
    }
}
