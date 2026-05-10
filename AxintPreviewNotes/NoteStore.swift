import Foundation

@MainActor
final class OrbitStore: ObservableObject {
    @Published private(set) var waypoints: [OrbitWaypoint] = []
    @Published var focusModeEnabled = true
    @Published var allowAgentWalkthrough = true
    @Published var selectedRegion = "Tokyo"

    private let storageKey = "ai.axint.orbit-showcase.waypoints"

    init() {
        load()
        if waypoints.isEmpty {
            seed()
        }
    }

    var pinnedWaypoints: [OrbitWaypoint] {
        waypoints
            .filter(\.isPinned)
            .sorted { $0.createdAt > $1.createdAt }
    }

    var readyWaypoints: [OrbitWaypoint] {
        waypoints
            .filter { $0.status != .blocked }
            .sorted { lhs, rhs in
                if lhs.isPinned != rhs.isPinned { return lhs.isPinned }
                return lhs.createdAt > rhs.createdAt
            }
    }

    var blockedCount: Int {
        waypoints.filter { $0.status == .blocked }.count
    }

    var bookedCount: Int {
        waypoints.filter { $0.status == .booked }.count
    }

    var completionRatio: Double {
        guard !waypoints.isEmpty else { return 0 }
        return Double(bookedCount) / Double(waypoints.count)
    }

    func add(
        title: String,
        location: String,
        detail: String,
        category: WaypointCategory,
        status: WaypointStatus
    ) {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDetail = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }

        waypoints.insert(
            OrbitWaypoint(
                title: cleanTitle,
                location: cleanLocation.isEmpty ? selectedRegion : cleanLocation,
                detail: cleanDetail.isEmpty ? "Added from Axint Cloud Preview." : cleanDetail,
                category: category,
                status: status,
                isPinned: waypoints.isEmpty
            ),
            at: 0
        )
        save()
    }

    func addDemoWaypoint() {
        add(
            title: "Neon garden dinner",
            location: "Shibuya Sky",
            detail: "Reserve the corner table, confirm dietary notes, and capture the view for the client walkthrough.",
            category: .food,
            status: .watch
        )
    }

    func togglePinned(_ waypoint: OrbitWaypoint) {
        update(waypoint) { $0.isPinned.toggle() }
    }

    func cycleStatus(_ waypoint: OrbitWaypoint) {
        update(waypoint) { item in
            switch item.status {
            case .ready: item.status = .booked
            case .booked: item.status = .watch
            case .watch: item.status = .blocked
            case .blocked: item.status = .ready
            }
        }
    }

    func resetDemoData() {
        waypoints.removeAll()
        seed()
    }

    private func update(_ waypoint: OrbitWaypoint, mutate: (inout OrbitWaypoint) -> Void) {
        guard let index = waypoints.firstIndex(where: { $0.id == waypoint.id }) else { return }
        mutate(&waypoints[index])
        save()
    }

    private func seed() {
        waypoints = [
            OrbitWaypoint(
                title: "Kissa midnight check-in",
                location: "Aoyama House",
                detail: "Suite key, lighting scene, luggage transfer, and late arrival note are ready.",
                category: .stay,
                status: .booked,
                isPinned: true
            ),
            OrbitWaypoint(
                title: "Team route rehearsal",
                location: "Ginza Line",
                detail: "Verify platform timing and elevator access before the morning client route.",
                category: .transit,
                status: .ready
            ),
            OrbitWaypoint(
                title: "Private ceramic studio",
                location: "Kiyosumi",
                detail: "Host approved. Agent should confirm guest count before marking this booked.",
                category: .culture,
                status: .watch
            ),
            OrbitWaypoint(
                title: "Rooftop chef table",
                location: "Ebisu",
                detail: "Payment link is missing, which gives the walkthrough a safe blocked state to report.",
                category: .food,
                status: .blocked
            ),
        ]
        save()
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([OrbitWaypoint].self, from: data)
        else {
            return
        }
        waypoints = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(waypoints) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
