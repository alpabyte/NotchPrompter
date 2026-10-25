import Foundation

public struct ScrollEngine {
    public private(set) var offset: Double = 0
    public private(set) var isPlaying = false
    public private(set) var maximumOffset: Double = .greatestFiniteMagnitude
    private var lastTick: TimeInterval?

    public init() {}

    public mutating func play() {
        if offset >= maximumOffset { offset = 0 }
        lastTick = nil
        isPlaying = true
    }

    public mutating func pause() {
        isPlaying = false
        lastTick = nil
    }

    public mutating func reset() {
        pause()
        offset = 0
    }

    public mutating func seek(to position: Double) {
        guard position.isFinite else { return }
        offset = min(max(0, position), maximumOffset)
    }

    public mutating func setMaximumOffset(_ maximum: Double) {
        guard maximum.isFinite else { return }
        maximumOffset = max(0, maximum)
        seek(to: offset)
        if offset >= maximumOffset { pause() }
    }

    public mutating func tick(at time: TimeInterval, speed: Double, canScroll: Bool = true) {
        guard time.isFinite else { return }
        defer { lastTick = time }
        guard isPlaying, canScroll, let previous = lastTick else { return }
        // A suspended app must not skip the script when it wakes.
        let elapsed = min(max(time - previous, 0), 0.1)
        seek(to: offset + max(0, speed) * elapsed)
        if offset >= maximumOffset { pause() }
    }
}

public enum AudioLevel {
    public static func smooth(previous: Float, sample: Float) -> Float {
        guard sample.isFinite else { return max(0, previous) }
        return max(0, previous) * 0.7 + max(0, sample) * 0.3
    }
}
