import SwiftUI
import HealthKit

struct ContentView: View {
    @EnvironmentObject private var hydrotherapyTimer: HydrotherapyTimer
    @StateObject private var healthKitHelper = HealthKitHelper()
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isLocked = true
    @State private var isLoading = false
    @State private var isPaused = false
    @State private var showExitButton = false
    @State private var startDate = Date()
    
    
    
    var body: some View {
        VStack {
            Text("Contrast Shower Timer")
                .font(.headline).multilineTextAlignment(.center)
            
            Spacer()
            
            if hydrotherapyTimer.timerState != .inactive {
                Text("Time Remaining: \(Int(hydrotherapyTimer.timeRemaining))")
                    .font(.caption)
            }
            
            Spacer()
            
            HStack {
                VStack {
                    Picker("Hot Duration", selection: $hydrotherapyTimer.hotDurationIndex) {
                        ForEach(0..<60) { second in
                            Text("\(second)").foregroundColor(.red).tag(second)
                        }
                    }
                    .frame(width: 50)
                    .clipped()
                    .pickerStyle(WheelPickerStyle())
                    .labelsHidden()
                    .disabled(hydrotherapyTimer.timerState != .inactive)
                    Text("🔥Hot\n(sec)").font(.footnote).multilineTextAlignment(.center)
                }
                VStack {
                    Picker("Laps", selection: $hydrotherapyTimer.repetitionsIndex) {
                        ForEach(0..<11) { lap in
                            Text("\(lap)").tag(lap)
                        }
                    }
                    .frame(width: 50)
                    .clipped()
                    .pickerStyle(WheelPickerStyle())
                    .labelsHidden()
                    .disabled(hydrotherapyTimer.timerState != .inactive)
                    Text("Laps").font(.footnote).multilineTextAlignment(.center)
                }
                VStack {
                    Picker("Cold Duration", selection: $hydrotherapyTimer.coldDurationIndex) {
                        ForEach(0..<60) { second in
                            Text("\(second)").foregroundColor(.blue).tag(second)
                        }
                    }
                    .frame(width: 50)
                    .clipped()
                    .pickerStyle(WheelPickerStyle())
                    .labelsHidden()
                    .disabled(hydrotherapyTimer.timerState != .inactive)
                    Text("❄️Cold\n(sec)").font(.footnote).multilineTextAlignment(.center)
                }
                
            }.alignmentGuide(.leading, computeValue: { d in d[.leading] })
            
            if hydrotherapyTimer.timerState == .inactive{
                UnlockButton(isLocked: $isLocked, isLoading: $isLoading).onChange(of: isLocked) {
                    isLocked in if !isLocked {
                        let config = hydrotherapyTimer.getTimerConfig()
                        hydrotherapyTimer.startTimer(config: config)
                    }
                }
            } else if hydrotherapyTimer.timerState == .running {
                Button("Pause") {
                    hydrotherapyTimer.timerState = .paused
                    isPaused = false
                    showExitButton = true
                }
            }
            else if hydrotherapyTimer.timerState == .paused {
                HStack{
                    Button("Resume") {
                        hydrotherapyTimer.resumeTimer()
                        isLocked = false
                        showExitButton = false
                    }
                    Button("Exit") {
                        hydrotherapyTimer.stopTimer()
                        isLocked = true
                        isLoading = false
                        showExitButton = false
                    }
                }
            }
        }.onChange(of: hydrotherapyTimer.timerState) { newTimerState in
            if newTimerState == .finished {
                isLocked = true
                hydrotherapyTimer.timerState = .inactive
                healthKitHelper.saveWorkout(startTime: Date.now, endTime: Date.now, calories: 0, distance: 0)
            }
        }
    }

}
