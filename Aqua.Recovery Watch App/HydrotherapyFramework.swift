import Foundation
import Combine
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

    // MARK: - WCSessionDelegate Methods

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion
    }

    public func sessionReachabilityDidChange(_ session: WCSession) {
        // Handle reachability change
    }

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

   @Published public var hotDurationIndex: Int = 0
   @Published public var coldDurationIndex: Int = 0
   @Published public var repetitionsIndex: Int = 0

   private var cancellables = Set<AnyCancellable>()
   private var timerCancellable: AnyCancellable?

   private let watchConnectivityCoordinator = WatchConnectivityCoordinator()



    public func startTimer(config: TimerConfig) {
        timerState = .running
        timeRemaining = config.hotDuration

        // Cancel any previous timer before starting a new one
        timerCancellable?.cancel()

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                if self.timeRemaining <= 0 {
                    self.sendHapticFeedback()
                    self.timerCancellable?.cancel()
                    self.timerState = .finished
                } else {
                    self.timeRemaining -= 1
                }
            }
        self.timerCancellable?.store(in: &cancellables)
    }

    public func pauseTimer() {
        timerState = .paused
        timerCancellable?.cancel()
    }

    public func resumeTimer() {
        if timerState == .paused {
            startTimer(config: TimerConfig(hotDuration: timeRemaining, coldDuration: timeRemaining, repetitions: 1))
        }
    }

    public func stopTimer() {
        timerState = .inactive
        timerCancellable?.cancel()
    }

    public func announce(bodyPart: String) {
        watchConnectivityCoordinator.announce(bodyPart: bodyPart)
    }

    private func sendHapticFeedback() {
        watchConnectivityCoordinator.announce(bodyPart: "wrist")
   }
    
    public func setPickerValues(from config: TimerConfig) {
           hotDurationIndex = Int(config.hotDuration / 60)
           coldDurationIndex = Int(config.coldDuration / 60)
           repetitionsIndex = config.repetitions - 1
       }

       // Add a method to get the TimerConfig based on the picker values
       public func getTimerConfig() -> TimerConfig {
           let hotDuration = Double(hotDurationIndex * 60)
           let coldDuration = Double(coldDurationIndex * 60)
           let repetitions = repetitionsIndex + 1

           return TimerConfig(hotDuration: hotDuration, coldDuration: coldDuration, repetitions: repetitions)
       }
}
