import Foundation
import AuthenticationServices
import Combine 
@MainActor
final class AuthViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoggedIn = false

    func login() {
        AuthService.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isLoggedIn = true
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

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
            let email = credential.email // only first time

            AuthService.appleLogin(
                appleUserId: appleUserId,
                email: email
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.isLoggedIn = true
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }

        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        isLoggedIn = false
    }
}
