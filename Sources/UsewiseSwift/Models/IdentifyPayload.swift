import Foundation

struct IdentifyPayload: Encodable {
    let anonymous_id: String
    let user_id: String
    let traits: [String: AnyCodable]?
}
