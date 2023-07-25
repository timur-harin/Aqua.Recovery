import SwiftUI


public struct DraggingComponent: View {

    @Binding var isLocked: Bool
    let isLoading: Bool
    let maxWidth: CGFloat

    @State private var width = CGFloat(50)
    private  let minWidth = CGFloat(50)

    public init(isLocked: Binding<Bool>, isLoading: Bool, maxWidth: CGFloat) {
        _isLocked = isLocked
        self.isLoading = isLoading
        self.maxWidth = maxWidth
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.red)
            .opacity(width / maxWidth)
            .frame(width: width)
            .overlay(
                Button(action: { }) {
                    ZStack {
                        image(name: "arrowshape.right.fill", isShown: isLocked)
                        progressView(isShown: isLoading)
                        image(name: "checkmark", isShown: !isLocked && !isLoading)
                    }
                    .animation(.easeIn(duration: 0.35).delay(0.2), value: !isLocked && !isLoading)
                }
                .buttonStyle(BaseButtonStyle())
                .disabled(!isLocked || isLoading),
                alignment: .trailing
            )

            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        guard isLocked else { return }
                    if value.translation.width > 0 {
                        width = min(max(value.translation.width + minWidth, minWidth), maxWidth)
                    }
                    }
                    .onEnded { value in
                        guard isLocked else { return }
                        if width < maxWidth {
                            width = minWidth
                            WKInterfaceDevice.current().play(.failure)
                        } else {
                            
                            WKInterfaceDevice.current().play(.success)
                            withAnimation(.spring().delay(0.5)) {
                                isLocked = false
                            }
                            
                        }
                    }
            )
            .animation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 0), value: width)

    }

    private func image(name: String, isShown: Bool) -> some View {
        Image(systemName: name)
            .font(.system(size: 20, weight: .regular, design: .rounded))
            .foregroundColor(Color.red)
            .frame(width: 42, height: 42)
            .background(RoundedRectangle(cornerRadius: 14).fill(.white))
            .padding(4)
            .opacity(isShown ? 1 : 0)
            .scaleEffect(isShown ? 1 : 0.01)
    }

    private func progressView(isShown: Bool) -> some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.white)
            .opacity(isShown ? 1 : 0)
            .scaleEffect(isShown ? 1 : 0.01)
    }

}
