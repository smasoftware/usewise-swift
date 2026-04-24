import Foundation

struct ProcessStartPayload: Encodable {
    let process_name: String
    let anonymous_id: String?
    let user_id: String?
    let properties: [String: AnyCodable]?
}

struct ProcessStepPayload: Encodable {
    let process_id: String
    let step_name: String
    let properties: [String: AnyCodable]?
}

struct ProcessCompletePayload: Encodable {
    let process_id: String
}

struct ProcessFailPayload: Encodable {
    let process_id: String
    let reason: String?
}

struct ProcessStartResponse: Decodable {
    let process_id: String
    let process_name: String
    let started_at: String
}

struct ProcessStepResponse: Decodable {
    let step_id: String
    let step_name: String
    let step_order: Int
    let duration_ms: Int
}

struct ProcessCompleteResponse: Decodable {
    let total_steps: Int
    let total_duration_ms: Int
}
