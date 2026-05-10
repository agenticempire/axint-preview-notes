import Foundation

struct OrbitWaypoint: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var location: String
    var detail: String
    var category: WaypointCategory
    var status: WaypointStatus
    var isPinned: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        location: String,
        detail: String,
        category: WaypointCategory = .stay,
        status: WaypointStatus = .ready,
        isPinned: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.location = location
        self.detail = detail
        self.category = category
        self.status = status
        self.isPinned = isPinned
        self.createdAt = createdAt
    }
}

enum WaypointCategory: String, CaseIterable, Codable, Identifiable {
    case stay = "Stay"
    case food = "Food"
    case culture = "Culture"
    case transit = "Transit"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .stay: "building.2"
        case .food: "fork.knife"
        case .culture: "sparkles"
        case .transit: "tram.fill"
        }
    }
}

enum WaypointStatus: String, CaseIterable, Codable, Identifiable {
    case ready = "Ready"
    case booked = "Booked"
    case watch = "Watch"
    case blocked = "Blocked"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .ready: "checkmark.seal"
        case .booked: "ticket"
        case .watch: "eye"
        case .blocked: "exclamationmark.triangle"
        }
    }
}
