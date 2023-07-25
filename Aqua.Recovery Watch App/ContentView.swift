import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var hydrotherapyTimer: HydrotherapyTimer
    @Environment(\.colorScheme) var colorScheme
    
    
   
    

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Contrast Shower Timer")
                    .font(.headline).multilineTextAlignment(.center)
                
                Spacer()
                
                if hydrotherapyTimer.timerState != .inactive {
                    Text("Time Remaining: \(Int(hydrotherapyTimer.timeRemaining))")
                        .font(.caption)
                }
                
                
                
                Spacer()
                
                HStack{
                    VStack{
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
                    VStack{
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
                    VStack{
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
                //            Button(
                //
                //                action: {
                //                if hydrotherapyTimer.timerState == .inactive {
                //                    let hotDuration = Double(hydrotherapyTimer.hotDurationIndex * 60)
                //                    let coldDuration = Double(hydrotherapyTimer.coldDurationIndex * 60)
                //                    let repetitions = hydrotherapyTimer.repetitionsIndex + 1
                //
                //                    hydrotherapyTimer.startTimer(config: TimerConfig(hotDuration: hotDuration, coldDuration: coldDuration, repetitions: repetitions))
                //                } else if hydrotherapyTimer.timerState == .running {
                //                    hydrotherapyTimer.pauseTimer()
                //                } else if hydrotherapyTimer.timerState == .paused {
                //                    hydrotherapyTimer.resumeTimer()
                //                }
                //            }) {
                //                Image(systemName: hydrotherapyTimer.timerState == .running ? "pause.circle.fill" : "play.circle.fill")
                //                    .font(.system(size: 50))
                //                    .foregroundColor(.blue)
                //            }
                //            swipe to start
                
                UnlockButton()
                
            }
        }
//        .edgesIgnoringSafeArea(.)
    }
      
}
