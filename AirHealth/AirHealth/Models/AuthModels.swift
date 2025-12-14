import Foundation

struct LoginResponse: Codable {
    let userId: String
    let email: String
    let handle: String
    let token: String
}
