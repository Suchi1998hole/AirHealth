import Foundation
import AuthenticationServices
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - Inputs

    @Published var email = ""
    @Published var password = ""

    // MARK: - Outputs

    @Published var isLoggedIn = false
    @Published var needsOnboarding = false
    @Published var errorMessage: String?

    // MARK: - Email Login

    func login() {
        AuthService.login(email: email, password: password) { result in
            switch result {
            case .success:
                self.isLoggedIn = true
                self.needsOnboarding = !AuthService.onboardingCompleted

            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Apple Login

    func loginWithApple(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):

            guard
                let credential = auth.credential as? ASAuthorizationAppleIDCredential
            else {
                errorMessage = "Invalid Apple credential"
                return
            }

            let appleUserId = credential.user
            let email = credential.email

            AuthService.appleLogin(
                appleUserId: appleUserId,
                email: email
            ) { result in
                switch result {
                case .success:
                    self.isLoggedIn = true
                    self.needsOnboarding = !AuthService.onboardingCompleted

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }

        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Logout

    func logout() {
        AuthService.logout()
        isLoggedIn = false
        needsOnboarding = false
        email = ""
        password = ""
        errorMessage = nil
    }
}
