import Foundation

enum AuthService {

    // Email + password login (optional)
    static func login(
        email: String,
        password: String,
        completion: @escaping (Result<LoginResponse, Error>) -> Void
    ) {
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]

        APIService.shared.post(
            url: APIConstants.login,
            body: body,
            responseType: LoginResponse.self,
            completion: completion
        )
    }

    // 🍎 Sign in with Apple
    static func appleLogin(
        appleUserId: String,
        email: String?,
        completion: @escaping (Result<LoginResponse, Error>) -> Void
    ) {
        var body: [String: Any] = [
            "appleUserId": appleUserId
        ]

        // Apple only sends email the FIRST time
        if let email = email {
            body["email"] = email
        }

        APIService.shared.post(
            url: APIConstants.appleLogin,
            body: body,
            responseType: LoginResponse.self,
            completion: completion
        )
    }
}
