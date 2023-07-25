import SwiftUI

@main
struct WatchApp: App {
    @StateObject private var hydrotherapyTimer = HydrotherapyTimer()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .environmentObject(hydrotherapyTimer)
        }
    }
}
