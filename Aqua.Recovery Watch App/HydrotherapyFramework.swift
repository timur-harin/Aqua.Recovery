import Foundation
import Combine
import WatchConnectivity
import SwiftUI

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
   @Published public var repetitionsTimer: Int = 0
   

   @Published public var hotDurationIndex: Int = 0
   @Published public var coldDurationIndex: Int = 0
   @Published public var repetitionsIndex: Int = 0
    

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
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                    currentDuration += 1
                } else {
                    if repetitions > 0 {
                        if isHot {
                            self.timeRemaining = coldDuration
                            isHot = false
                        } else {
                            self.timeRemaining = hotDuration
                            isHot = true
                            repetitions -= 1
                            self.repetitionsTimer += 1
                        }
                    } else {
                        self.timerState = .finished
                        self.timerCancellable?.cancel()
                        self.sendHapticFeedback()
                    }
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
