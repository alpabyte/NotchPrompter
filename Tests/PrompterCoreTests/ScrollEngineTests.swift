import XCTest
@testable import PrompterCore

final class ScrollEngineTests: XCTestCase {
    func testPlaybackUsesElapsedTime() {
        var engine = ScrollEngine()
        engine.play()
        engine.tick(at: 100, speed: 20)
        engine.tick(at: 100.05, speed: 20)
        XCTAssertEqual(engine.offset, 1, accuracy: 0.0001)
    }

    func testPauseAndResumePreservePosition() {
        var engine = ScrollEngine()
        engine.seek(to: 50)
        engine.play()
        engine.tick(at: 1, speed: 20)
        engine.pause()
        engine.tick(at: 10, speed: 20)
        XCTAssertEqual(engine.offset, 50)
        engine.play()
        engine.tick(at: 20, speed: 20)
        engine.tick(at: 20.05, speed: 20)
        XCTAssertEqual(engine.offset, 51, accuracy: 0.0001)
        engine.reset()
        XCTAssertEqual(engine.offset, 0)
        XCTAssertFalse(engine.isPlaying)
    }

    func testSpeechAndHoverGatingDoNotAccumulateTime() {
        var engine = ScrollEngine()
        engine.play()
        engine.tick(at: 1, speed: 10)
        engine.tick(at: 5, speed: 10, canScroll: false)
        engine.tick(at: 5.05, speed: 10)
        XCTAssertEqual(engine.offset, 0.5, accuracy: 0.0001)
    }

    func testSleepDoesNotSkipScript() {
        var engine = ScrollEngine()
        engine.play()
        engine.tick(at: 1, speed: 10)
        engine.tick(at: 1000, speed: 10)
        XCTAssertEqual(engine.offset, 1, accuracy: 0.0001)
    }

    func testBoundsEndAndReplay() {
        var engine = ScrollEngine()
        engine.setMaximumOffset(10)
        engine.seek(to: -40)
        XCTAssertEqual(engine.offset, 0)
        engine.seek(to: 100)
        XCTAssertEqual(engine.offset, 10)
        engine.play()
        XCTAssertEqual(engine.offset, 0)
        engine.seek(to: 9.5)
        engine.tick(at: 1, speed: 10)
        engine.tick(at: 1.1, speed: 10)
        XCTAssertEqual(engine.offset, 10)
        XCTAssertFalse(engine.isPlaying)
    }

    func testInvalidInputAndBackwardsClock() {
        var engine = ScrollEngine()
        engine.seek(to: 20)
        engine.seek(to: .nan)
        engine.play()
        engine.tick(at: 10, speed: 10)
        engine.tick(at: 9, speed: 10)
        XCTAssertEqual(engine.offset, 20)
    }

    func testAudioSmoothingIsNonnegativeAndDetectsSpeech() {
        XCTAssertEqual(AudioLevel.smooth(previous: 0, sample: 0), 0)
        let speech = AudioLevel.smooth(previous: 0, sample: 0.1)
        XCTAssertEqual(speech, 0.03, accuracy: 0.0001)
        XCTAssertGreaterThan(speech, 0.01)
        XCTAssertLessThan(AudioLevel.smooth(previous: speech, sample: 0), speech)
    }
}
