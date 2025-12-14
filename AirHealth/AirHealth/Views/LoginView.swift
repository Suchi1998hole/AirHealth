import SwiftUI
import AuthenticationServices

struct LoginView: View {

    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {

            Spacer()

            Text("AirHealth")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Email", text: $authVM.email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            SecureField("Password", text: $authVM.password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button("Login") {
                authVM.login()
            }
            .buttonStyle(.borderedProminent)

            Divider()

            // 🍎 Sign in with Apple
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.email, .fullName]
                },
                onCompletion: { result in
                    authVM.loginWithApple(result: result)
                }
            )
            .frame(height: 48)

            Spacer()
        }
        .padding()
    }
}
