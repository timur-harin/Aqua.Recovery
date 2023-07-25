import Combine
import Foundation
import SwiftUI
import WatchConnectivity

public class WatchConnectivityCoordinator: NSObject, WCSessionDelegate {
    private let session: WCSession

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }

    func announce(bodyPart: String) {
        if session.isReachable {
            session.sendMessage(["bodyPart": bodyPart], replyHandler: nil, errorHandler: nil)
        }
    }

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    public func sessionReachabilityDidChange(_ session: WCSession) {}
}

public struct TimerConfig {
    var hotDuration: TimeInterval
    var coldDuration: TimeInterval
    var repetitions: Int
}

public enum TimerState {
    case inactive
    case running
    case paused
    case finished
}

public class HydrotherapyTimer: ObservableObject {
    @Published public var timerState: TimerState = .inactive
    @Published public var timeRemaining: TimeInterval = 0
    @Published public var repetitionsTimer: Int = 0

    @Published public var hotDurationIndex: Int = 0
    @Published public var coldDurationIndex: Int = 0
    @Published public var repetitionsIndex: Int = 0

    private var remainingTime: TimeInterval = 0

    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?

    private let watchConnectivityCoordinator = WatchConnectivityCoordinator()

    public func startTimer(config: TimerConfig) {
        timerState = .running

        let hotDuration = config.hotDuration
        let coldDuration = config.coldDuration
        var repetitions = config.repetitions
        var isHot = true
        var currentDuration: TimeInterval = 0

        timeRemaining = hotDuration

        timerCancellable?.cancel()

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timerState == .running {
                    if self.timeRemaining > 0 {
                        self.timeRemaining -= 1
                        currentDuration += 1
                    } else {
                      
                        if repetitions > 0 {
                            self.sendHapticFeedback(isHot: false)
                            if isHot {
                                self.timeRemaining = coldDuration
                                isHot = false
                            } else {
                                self.sendHapticFeedback(isHot: true)
                                self.timeRemaining = hotDuration
                                isHot = true
                                repetitions -= 1
                                self.repetitionsTimer += 1
                            }
                        } else {
                            self.timerState = .finished
                            self.timerCancellable?.cancel()
                            self.soundEnd()
                            
                        }
                    }
                } else if self.timerState == .paused {}
            }
    }

    public func pauseTimer() {
        timerState = .paused
        remainingTime = timeRemaining
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    public func reset() {
        timerState = .inactive
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    public func resumeTimer() {
        timerState = .running
    }

    public func stopTimer() {
        timerState = .inactive
        timerCancellable?.cancel()
    }

    public func announce(bodyPart: String) {
        watchConnectivityCoordinator.announce(bodyPart: bodyPart)
    }

    private func sendHapticFeedback(isHot: Bool) {
        WKInterfaceDevice.current().play(isHot ? .failure : .success)
    }
    
    private func soundEnd(){
        WKInterfaceDevice.current().play(.success)
    
    }

    public func setPickerValues(from config: TimerConfig) {
        hotDurationIndex = Int(config.hotDuration)
        coldDurationIndex = Int(config.coldDuration)
        repetitionsIndex = config.repetitions
    }

    public func getTimerConfig() -> TimerConfig {
        let hotDuration = Double(hotDurationIndex)
        let coldDuration = Double(coldDurationIndex)
        let repetitions = repetitionsIndex

        return TimerConfig(hotDuration: hotDuration, coldDuration: coldDuration, repetitions: repetitions)
    }
}

extension AnyCancellable {
    private enum TimerCancellableKey {
        static var remainingTime: TimeInterval = 0
    }

    var remainingTime: TimeInterval {
        get {
            guard let value = objc_getAssociatedObject(self, &TimerCancellableKey.remainingTime) as? TimeInterval else {
                return 0
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, &TimerCancellableKey.remainingTime, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
