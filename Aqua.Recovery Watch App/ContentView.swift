import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var hydrotherapyTimer: HydrotherapyTimer
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isLocked = true
    @State private var isLoading = false
    @State private var isPaused = false
    @State private var showExitButton = false
    
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
                    Text("❄️Cold\n(sec)").font(.footnote).multilineTextAlignment(.center)
                }
                    
            }.alignmentGuide(.leading, computeValue: { d in d[.leading] })
               
            if hydrotherapyTimer.timerState == .inactive {
                UnlockButton(isLocked: $isLocked, isLoading: $isLoading).onChange(of: isLocked) { isLocked in
                    if !isLocked {
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
            } else if hydrotherapyTimer.timerState == .paused {
                Button("Exit") {
                    hydrotherapyTimer.stopTimer()
                    isLocked = true
                    showExitButton = false
                }
            }
        }
    }
}
