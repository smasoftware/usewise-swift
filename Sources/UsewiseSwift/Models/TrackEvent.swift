import Foundation

public struct ElementData: Encodable {
    public let tag: String?
    public let text: String?
    public let id: String?

    public init(tag: String? = nil, text: String? = nil, id: String? = nil) {
        self.tag = tag
        self.text = text
        self.id = id
    }
}

public struct PageData: Encodable {
    public let url: String?
    public let title: String?
    public let referrer: String?

    public init(url: String? = nil, title: String? = nil, referrer: String? = nil) {
        self.url = url
        self.title = title
        self.referrer = referrer
    }
}

public struct ScreenData: Encodable {
    public let width: Int?
    public let height: Int?

    public init(width: Int? = nil, height: Int? = nil) {
        self.width = width
        self.height = height
    }
}

public struct DeviceContextData: Encodable {
    public let device_os: String?
    public let device_model: String?
    public let app_version: String?
    public let is_vpn: Bool?
    public let is_jailbroken: Bool?

    enum CodingKeys: String, CodingKey {
        case device_os, device_model, app_version, is_vpn, is_jailbroken
    }
}

struct TrackEvent: Encodable {
    let event: String
    let anonymous_id: String?
    let user_id: String?
    let event_uuid: String
    let timestamp: String
    let properties: [String: AnyCodable]?
    let element: ElementData?
    let page: PageData?
    let screen: ScreenData?
    let context: DeviceContextData?
}

struct BatchPayload: Encodable {
    let batch: [TrackEvent]
}
