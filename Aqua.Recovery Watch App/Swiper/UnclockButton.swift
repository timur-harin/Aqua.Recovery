import SwiftUI

struct UnlockButton: View {

  @State private var isLocked = true
  @State private var isLoading = false
  
  var body: some View {
    GeometryReader { geometry in
        ZStack(alignment: .leading) {
        BackgroundComponent()
        DraggingComponent(isLocked: $isLocked, isLoading: isLoading, maxWidth: geometry.size.width)
      }
    }
    .frame(height: 50)
    .padding()
    .onChange(of: isLocked) { isLocked in
      guard !isLocked else { return }
      simulateRequest()
    }
  }
  private func simulateRequest() {
    isLoading = true

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      isLoading = false
    }
  }
}
