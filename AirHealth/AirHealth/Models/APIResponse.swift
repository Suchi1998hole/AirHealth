import Foundation

struct APIGatewayResponse<T: Codable>: Codable {
    let statusCode: Int
    let body: String
}
