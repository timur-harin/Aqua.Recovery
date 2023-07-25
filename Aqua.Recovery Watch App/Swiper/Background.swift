import SwiftUI

public struct BackgroundComponent: View {

    @State private var hueRotation = false

    public init() { }

    public var body: some View {
        ZStack(alignment: .leading)  {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.red.opacity(0.6), Color.blue.opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .hueRotation(.degrees(hueRotation ? 20 : -20))

            Text("Slide to start")
                .font(.footnote)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                hueRotation.toggle()
            }
        }
    }

}
