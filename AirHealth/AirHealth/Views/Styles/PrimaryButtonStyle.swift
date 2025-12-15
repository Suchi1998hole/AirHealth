import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {

    let enabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(enabled ? Color.black : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
