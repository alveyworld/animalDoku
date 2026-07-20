import XCTest
@testable import AnimalDoku

final class FakeClock: Clock {
    var now: TimeInterval = 0

    func advance(_ seconds: TimeInterval) {
        now += seconds
    }
}

final class TimerServiceTests: XCTestCase {
    func testTickIncrementsElapsedSeconds() {
        let clock = FakeClock()
        let timer = TimerService(clock: clock)

        timer.start()
        clock.advance(1)
        timer.tick()

        XCTAssertEqual(timer.elapsedSeconds, 1)
    }

    func testPauseDoesNotAccumulateBackgroundTime() {
        let clock = FakeClock()
        let timer = TimerService(clock: clock)

        timer.start()
        clock.advance(5)
        timer.tick()
        XCTAssertEqual(timer.elapsedSeconds, 5)

        timer.pause()
        clock.advance(10)
        timer.tick()
        XCTAssertEqual(timer.elapsedSeconds, 5)

        timer.resume()
        clock.advance(2)
        timer.tick()
        XCTAssertEqual(timer.elapsedSeconds, 7)
    }

    func testStopFreezesElapsedSeconds() {
        let clock = FakeClock()
        let timer = TimerService(clock: clock)

        timer.start()
        clock.advance(3)
        timer.stop()
        XCTAssertEqual(timer.elapsedSeconds, 3)

        clock.advance(20)
        timer.tick()
        timer.resume()
        timer.start()
        clock.advance(5)
        timer.tick()

        XCTAssertEqual(timer.elapsedSeconds, 3)
    }

    func testResetClearsElapsedSeconds() {
        let clock = FakeClock()
        let timer = TimerService(clock: clock)

        timer.start()
        clock.advance(12)
        timer.tick()
        timer.reset()

        XCTAssertEqual(timer.elapsedSeconds, 0)

        timer.start()
        clock.advance(1)
        timer.tick()
        XCTAssertEqual(timer.elapsedSeconds, 1)
    }

    func testDisplayFormatsAsMMSS() {
        XCTAssertEqual(ElapsedTimeFormatting.display(seconds: 125), "02:05")
        XCTAssertEqual(ElapsedTimeFormatting.display(seconds: 0), "00:00")
        XCTAssertEqual(ElapsedTimeFormatting.display(seconds: 59), "00:59")
        XCTAssertEqual(ElapsedTimeFormatting.display(seconds: 3600), "60:00")
    }

    func testAccessibilityLabelUsesSpokenUnits() {
        XCTAssertEqual(
            ElapsedTimeFormatting.accessibilityLabel(seconds: 125),
            "2 minutes 5 seconds"
        )
        XCTAssertEqual(
            ElapsedTimeFormatting.accessibilityLabel(seconds: 61),
            "1 minute 1 second"
        )
        XCTAssertEqual(
            ElapsedTimeFormatting.accessibilityLabel(seconds: 0),
            "0 seconds"
        )
    }
}
