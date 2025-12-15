import Foundation
import AuthenticationServices

final class AuthService {

    // MARK: - Networking

    private static let session = URLSession.shared

    // MARK: - Session State

    static private(set) var authToken: String?
    static private(set) var currentUserId: String?
    static private(set) var onboardingCompleted: Bool = false

    // MARK: - Email / Password Login

    static func login(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var request = URLRequest(url: URL(string: APIConstants.login)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "email": email,
            "password": password
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        session.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(AuthError.invalidResponse))
                }
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

                guard
                    let userId = json?["userId"] as? String,
                    let token = json?["token"] as? String
                else {
                    throw AuthError.invalidCredentials
                }

                self.currentUserId = userId
                self.authToken = token
                self.onboardingCompleted = json?["onboardingCompleted"] as? Bool ?? false

                DispatchQueue.main.async {
                    completion(.success(()))
                }

            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Apple Login

    static func appleLogin(
        appleUserId: String,
        email: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var request = URLRequest(url: URL(string: APIConstants.appleLogin)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "appleUserId": appleUserId,
            "email": email ?? ""
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        session.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(AuthError.invalidResponse))
                }
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

                guard
                    let userId = json?["userId"] as? String,
                    let token = json?["token"] as? String
                else {
                    throw AuthError.invalidResponse
                }

                self.currentUserId = userId
                self.authToken = token
                self.onboardingCompleted = json?["onboardingCompleted"] as? Bool ?? false

                DispatchQueue.main.async {
                    completion(.success(()))
                }

            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Update Onboarding

    static func updateOnboarding(
        payload: [String: Any],
        completion: @escaping () -> Void
    ) {
        print("🧠 AuthService.updateOnboarding payload:", payload)

        // 🔥 PRINT THE USER ID EXPLICITLY
        print("🧠 userId being sent:", payload["userId"] ?? "MISSING")
        var request = URLRequest(url: URL(string: APIConstants.updateOnboarding)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        session.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                self.onboardingCompleted = true
                completion()
            }
        }.resume()
    }

    // MARK: - Logout

    static func logout() {
        authToken = nil
        currentUserId = nil
        onboardingCompleted = false
    }
}

// MARK: - Errors

enum AuthError: LocalizedError {
    case invalidCredentials
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password."
        case .invalidResponse:
            return "Invalid server response."
        }
    }
}

