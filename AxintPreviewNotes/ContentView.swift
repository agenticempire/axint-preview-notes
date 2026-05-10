import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: OrbitStore

    var body: some View {
        TabView {
            OverviewView()
                .tabItem {
                    Label("Overview", systemImage: "sparkle.magnifyingglass")
                }

            ItineraryView()
                .tabItem {
                    Label("Itinerary", systemImage: "map")
                }

            PlanView()
                .tabItem {
                    Label("Plan", systemImage: "square.and.pencil")
                }

            StudioView()
                .tabItem {
                    Label("Studio", systemImage: "slider.horizontal.3")
                }
        }
        .tint(OrbitPalette.signal)
        .background(OrbitPalette.deep)
        .toolbarBackground(OrbitPalette.deepPanel, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

private struct OverviewView: View {
    @EnvironmentObject private var store: OrbitStore
    @State private var animateMap = false

    var body: some View {
        NavigationStack {
            ScrollView {
                OverviewContent(animateMap: animateMap)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 150)
            }
            .background(OrbitBackground())
            .overlay(alignment: .bottom) {
                BottomTabScrim()
            }
            .navigationTitle("Orbit")
            .toolbar {
                Button("Reset") {
                    store.resetDemoData()
                }
                .accessibilityIdentifier("button.reset-demo")
            }
            .onAppear {
                withAnimation(.smooth(duration: 2.8).repeatForever(autoreverses: true)) {
                    animateMap = true
                }
            }
        }
    }
}

private struct OverviewContent: View {
    @EnvironmentObject private var store: OrbitStore
    let animateMap: Bool

    private let metricColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HeroMapCard(animateMap: animateMap)
                .accessibilityIdentifier("card.hero-map")

            Button {
                store.addDemoWaypoint()
            } label: {
                Label("Add showcase stop", systemImage: "plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(OrbitPrimaryButtonStyle())
            .accessibilityIdentifier("button.add-showcase-stop")

            LazyVGrid(columns: metricColumns, spacing: 12) {
                MetricTile(value: "\(store.waypoints.count)", label: "Stops", detail: "Tokyo loop")
                MetricTile(value: "\(store.bookedCount)", label: "Booked", detail: "Ready to demo")
                MetricTile(value: "\(store.blockedCount)", label: "Blocked", detail: "Agent target")
            }
            .accessibilityIdentifier("overview.metrics")

            VStack(alignment: .leading, spacing: 14) {
                SectionLabel("Priority route")

                ForEach(store.pinnedWaypoints.prefix(2)) { waypoint in
                    WaypointCard(waypoint: waypoint, compact: true)
                }

                if store.pinnedWaypoints.isEmpty {
                    EmptyState(
                        title: "No priority stops",
                        subtitle: "Pin a stop from the itinerary to place it in the command view."
                    )
                }
            }

            AgentProofCard()
                .accessibilityIdentifier("card.agent-proof")
        }
    }
}

private struct ItineraryView: View {
    @EnvironmentObject private var store: OrbitStore
    @State private var search = ""

    private var filteredWaypoints: [OrbitWaypoint] {
        guard !search.isEmpty else { return store.readyWaypoints }
        return store.waypoints.filter {
            $0.title.localizedCaseInsensitiveContains(search) ||
            $0.location.localizedCaseInsensitiveContains(search) ||
            $0.detail.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(filteredWaypoints) { waypoint in
                        VStack(spacing: 10) {
                            WaypointCard(waypoint: waypoint)

                            HStack(spacing: 10) {
                                Button(waypoint.isPinned ? "Unpin" : "Pin") {
                                    store.togglePinned(waypoint)
                                }
                                .buttonStyle(OrbitSecondaryButtonStyle())
                                .accessibilityIdentifier("button.pin.\(waypoint.id.uuidString)")

                                Button("Cycle status") {
                                    store.cycleStatus(waypoint)
                                }
                                .buttonStyle(OrbitPrimaryButtonStyle())
                                .accessibilityIdentifier("button.status.\(waypoint.id.uuidString)")
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 130)
            }
            .background(OrbitBackground())
            .overlay(alignment: .bottom) {
                BottomTabScrim()
            }
            .navigationTitle("Itinerary")
            .searchable(text: $search, prompt: "Search route")
            .accessibilityIdentifier("field.search-route")
        }
    }
}

private struct PlanView: View {
    @EnvironmentObject private var store: OrbitStore
    @State private var title = ""
    @State private var location = ""
    @State private var detail = ""
    @State private var category: WaypointCategory = .culture
    @State private var status: WaypointStatus = .ready
    @State private var message = "Ready for a clean walkthrough"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Create a better stop.")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .tracking(-1.1)
                            .foregroundStyle(OrbitPalette.ink)

                        Text("The form gives Axint Cloud real text entry, segmented controls, visible state changes, and local persistence to prove.")
                            .font(.callout)
                            .foregroundStyle(OrbitPalette.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    TextField("Stop title", text: $title)
                        .textFieldStyle(OrbitFieldStyle())
                        .accessibilityIdentifier("field.stop-title")

                    TextField("Location", text: $location)
                        .textFieldStyle(OrbitFieldStyle())
                        .accessibilityIdentifier("field.stop-location")

                    TextField("Briefing note", text: $detail, axis: .vertical)
                        .lineLimit(5, reservesSpace: true)
                        .textFieldStyle(OrbitFieldStyle())
                        .accessibilityIdentifier("field.stop-detail")

                    Picker("Category", selection: $category) {
                        ForEach(WaypointCategory.allCases) { option in
                            Label(option.rawValue, systemImage: option.symbol)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("picker.stop-category")

                    Picker("Status", selection: $status) {
                        ForEach(WaypointStatus.allCases) { option in
                            Label(option.rawValue, systemImage: option.symbol)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("picker.stop-status")

                    Button {
                        store.add(
                            title: title,
                            location: location,
                            detail: detail,
                            category: category,
                            status: status
                        )
                        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            message = "Add a title before saving"
                        } else {
                            message = "Saved: \(title)"
                            title = ""
                            location = ""
                            detail = ""
                            category = .culture
                            status = .ready
                        }
                    } label: {
                        Label("Save stop", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(OrbitPrimaryButtonStyle())
                    .accessibilityIdentifier("button.save-stop")

                    Button {
                        title = "Lantern alley recording"
                        location = "Golden Gai"
                        detail = "Add this as a safe demo stop. It should show up immediately in the itinerary."
                        category = .culture
                        status = .ready
                        message = "Draft filled"
                    } label: {
                        Label("Fill premium draft", systemImage: "wand.and.stars")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(OrbitSecondaryButtonStyle())
                    .accessibilityIdentifier("button.fill-demo-draft")

                    Text(message)
                        .font(.headline.monospaced())
                        .foregroundStyle(OrbitPalette.signal)
                        .padding(.top, 4)
                        .accessibilityIdentifier("text.saved-message")
                }
                .padding(20)
                .padding(.bottom, 130)
            }
            .background(OrbitBackground())
            .overlay(alignment: .bottom) {
                BottomTabScrim()
            }
            .navigationTitle("Plan")
        }
    }
}

private struct StudioView: View {
    @EnvironmentObject private var store: OrbitStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cloud studio")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .tracking(-1)

                        Text("A compact settings surface for AI walkthrough policies, recording modes, and demo state.")
                            .foregroundStyle(OrbitPalette.muted)
                    }

                    StudioToggle(
                        title: "Allow AI walkthrough",
                        subtitle: "The preview agent can tap safe controls and generate a replay flow.",
                        isOn: $store.allowAgentWalkthrough
                    )
                    .accessibilityIdentifier("toggle.agent-walkthrough")

                    StudioToggle(
                        title: "Focus mode",
                        subtitle: "Hide risky actions during demo recordings.",
                        isOn: $store.focusModeEnabled
                    )
                    .accessibilityIdentifier("toggle.focus-mode")

                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel("Region")
                        Picker("Region", selection: $store.selectedRegion) {
                            ForEach(["Tokyo", "Kyoto", "Seoul", "Copenhagen"], id: \.self) { region in
                                Text(region).tag(region)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("picker.region")
                    }
                    .padding(16)
                    .background(OrbitSurface(cornerRadius: 26))

                    Button {
                        store.resetDemoData()
                    } label: {
                        Label("Reset showcase data", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(OrbitSecondaryButtonStyle())
                    .accessibilityIdentifier("button.reset-showcase-data")

                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel("Artifacts")
                        ArtifactRow(name: "walkthrough.mp4", detail: "Ready after recording")
                        ArtifactRow(name: "screen-map.json", detail: "\(store.waypoints.count) stops indexed")
                        ArtifactRow(name: "repair-packet.md", detail: "\(store.blockedCount) blocked flow")
                    }
                    .padding(16)
                    .background(OrbitSurface(cornerRadius: 26))
                    .accessibilityIdentifier("panel.artifacts")
                }
                .padding(20)
                .padding(.bottom, 130)
            }
            .background(OrbitBackground())
            .overlay(alignment: .bottom) {
                BottomTabScrim()
            }
            .navigationTitle("Studio")
        }
    }
}

private struct HeroMapCard: View {
    let animateMap: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            OrbitPalette.deepPanel,
                            OrbitPalette.panel,
                            OrbitPalette.signal.opacity(0.42),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            MapGrid()
                .opacity(0.34)
                .offset(x: animateMap ? 12 : -8, y: animateMap ? -10 : 8)

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 16) {
                    Text("Sample app")
                        .font(.caption.monospaced().weight(.bold))
                        .textCase(.uppercase)
                        .tracking(1.8)
                        .foregroundStyle(OrbitPalette.signal)

                    Spacer(minLength: 8)

                    GaugeRing(progress: 0.74)
                        .frame(width: 86, height: 86)
                }

                Text("Orbit plans a Tokyo launch in the simulator.")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .tracking(-1.1)
                    .lineLimit(3)
                    .foregroundStyle(OrbitPalette.ink)

                Text("A polished native fixture for Axint Cloud: tabs, forms, animated cards, settings, local data, and a safe blocked state for AI repair packets.")
                    .font(.callout)
                    .lineSpacing(3)
                    .foregroundStyle(OrbitPalette.muted)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    StatusPill(title: "1080p", systemImage: "display")
                    StatusPill(title: "AI safe", systemImage: "checkmark.shield")
                    StatusPill(title: "Local data", systemImage: "internaldrive")
                }
            }
            .padding(22)
        }
        .frame(minHeight: 324)
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(OrbitPalette.hairline, lineWidth: 1)
        }
    }
}

private struct MapGrid: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                ForEach(0..<8) { index in
                    Rectangle()
                        .fill(OrbitPalette.ink.opacity(0.12))
                        .frame(width: width * 1.2, height: 1)
                        .rotationEffect(.degrees(Double(index) * 14 - 38))
                        .offset(y: CGFloat(index - 3) * height * 0.1)
                }

                ForEach(0..<4) { index in
                    Circle()
                        .fill(index == 2 ? OrbitPalette.signal : OrbitPalette.ink.opacity(0.72))
                        .frame(width: index == 2 ? 13 : 9, height: index == 2 ? 13 : 9)
                        .position(
                            x: width * [0.22, 0.42, 0.68, 0.82][index],
                            y: height * [0.38, 0.62, 0.34, 0.72][index]
                        )
                }
            }
        }
    }
}

private struct BottomTabScrim: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: OrbitPalette.deep.opacity(0), location: 0),
                .init(color: OrbitPalette.deep.opacity(0), location: 0.28),
                .init(color: OrbitPalette.deep.opacity(0.96), location: 0.72),
                .init(color: OrbitPalette.deep, location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 185)
        .allowsHitTesting(false)
    }
}

private struct GaugeRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(OrbitPalette.ink.opacity(0.12), lineWidth: 10)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    OrbitPalette.signal,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text("74")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                Text("ready")
                    .font(.caption2.monospaced().weight(.bold))
                    .foregroundStyle(OrbitPalette.muted)
            }
        }
    }
}

private struct MetricTile: View {
    let value: String
    let label: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .contentTransition(.numericText())

            Text(label)
                .font(.caption.monospaced().weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(OrbitPalette.muted)

            Text(detail)
                .font(.caption)
                .foregroundStyle(OrbitPalette.quiet)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(OrbitSurface(cornerRadius: 24))
    }
}

private struct WaypointCard: View {
    let waypoint: OrbitWaypoint
    var compact = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 10 : 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(statusColor.opacity(0.18))
                    Image(systemName: waypoint.category.symbol)
                        .font(.headline)
                        .foregroundStyle(statusColor)
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 4) {
                    Text(waypoint.title)
                        .font(.headline)
                        .foregroundStyle(OrbitPalette.ink)

                    Text(waypoint.location)
                        .font(.caption.monospaced().weight(.semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(OrbitPalette.signal)
                }

                Spacer()

                Image(systemName: waypoint.status.symbol)
                    .foregroundStyle(statusColor)
                    .accessibilityHidden(true)
            }

            Text(waypoint.detail)
                .font(.subheadline)
                .lineSpacing(2)
                .foregroundStyle(OrbitPalette.muted)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                StatusPill(title: waypoint.category.rawValue, systemImage: waypoint.category.symbol)
                StatusPill(title: waypoint.status.rawValue, systemImage: waypoint.status.symbol)
                if waypoint.isPinned {
                    StatusPill(title: "Pinned", systemImage: "pin.fill")
                }
            }
        }
        .padding(compact ? 14 : 16)
        .background(OrbitSurface(cornerRadius: compact ? 24 : 28))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("waypoint-card.\(waypoint.title)")
    }

    private var statusColor: Color {
        switch waypoint.status {
        case .ready: OrbitPalette.green
        case .booked: OrbitPalette.signal
        case .watch: OrbitPalette.gold
        case .blocked: OrbitPalette.red
        }
    }
}

private struct AgentProofCard: View {
    private let proofColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionLabel("Agent proof")
                Spacer()
                Text("safe")
                    .font(.caption.monospaced().weight(.bold))
                    .foregroundStyle(OrbitPalette.green)
            }

            LazyVGrid(columns: proofColumns, spacing: 8) {
                ProofStep(number: "01", title: "Tap")
                ProofStep(number: "02", title: "Type")
                ProofStep(number: "03", title: "Save")
                ProofStep(number: "04", title: "Replay")
            }

            Text("The sample is built for repeatable AI walkthroughs: clear labels, safe settings, and one blocked flow that should become a repair packet instead of a destructive action.")
                .font(.footnote)
                .lineSpacing(2)
                .foregroundStyle(OrbitPalette.muted)
        }
        .padding(16)
        .background(OrbitSurface(cornerRadius: 28))
    }
}

private struct ProofStep: View {
    let number: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Text(number)
                .font(.caption.monospaced().weight(.bold))
                .foregroundStyle(OrbitPalette.signal)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(OrbitPalette.ink)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(OrbitPalette.ink.opacity(0.045), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct StudioToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(OrbitPalette.ink)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(OrbitPalette.muted)
            }
        }
        .toggleStyle(.switch)
        .padding(16)
        .background(OrbitSurface(cornerRadius: 26))
    }
}

private struct ArtifactRow: View {
    let name: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text")
                .foregroundStyle(OrbitPalette.signal)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(OrbitPalette.muted)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

private struct StatusPill: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption2.monospaced().weight(.bold))
            .textCase(.uppercase)
            .foregroundStyle(OrbitPalette.ink.opacity(0.82))
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(OrbitPalette.ink.opacity(0.07), in: Capsule())
    }
}

private struct SectionLabel: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.caption.monospaced().weight(.bold))
            .tracking(1.4)
            .textCase(.uppercase)
            .foregroundStyle(OrbitPalette.muted)
    }
}

private struct EmptyState: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(OrbitPalette.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(OrbitSurface(cornerRadius: 26))
    }
}

private struct OrbitFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .foregroundStyle(OrbitPalette.ink)
            .background(OrbitSurface(cornerRadius: 20))
    }
}

private struct OrbitPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 15)
            .padding(.horizontal, 18)
            .foregroundStyle(OrbitPalette.deep)
            .background(OrbitPalette.signal, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .animation(.smooth(duration: 0.18), value: configuration.isPressed)
    }
}

private struct OrbitSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .foregroundStyle(OrbitPalette.ink)
            .background(OrbitPalette.ink.opacity(0.08), in: RoundedRectangle(cornerRadius: 19, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .stroke(OrbitPalette.hairline, lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .animation(.smooth(duration: 0.18), value: configuration.isPressed)
    }
}

private struct OrbitSurface: View {
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        OrbitPalette.panel.opacity(0.96),
                        OrbitPalette.panel2.opacity(0.92),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(OrbitPalette.hairline, lineWidth: 1)
            }
    }
}

private struct OrbitBackground: View {
    var body: some View {
        ZStack {
            OrbitPalette.deep
                .ignoresSafeArea()

            RadialGradient(
                colors: [OrbitPalette.signal.opacity(0.32), .clear],
                center: .topTrailing,
                startRadius: 40,
                endRadius: 460
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [OrbitPalette.green.opacity(0.16), .clear],
                center: .bottomLeading,
                startRadius: 40,
                endRadius: 380
            )
            .ignoresSafeArea()
        }
    }
}

private enum OrbitPalette {
    static let deep = Color(red: 0.030, green: 0.032, blue: 0.035)
    static let deepPanel = Color(red: 0.055, green: 0.060, blue: 0.066)
    static let panel = Color(red: 0.082, green: 0.086, blue: 0.090)
    static let panel2 = Color(red: 0.120, green: 0.118, blue: 0.108)
    static let ink = Color(red: 0.960, green: 0.948, blue: 0.910)
    static let muted = Color(red: 0.700, green: 0.690, blue: 0.650)
    static let quiet = Color(red: 0.500, green: 0.492, blue: 0.462)
    static let signal = Color(red: 0.960, green: 0.540, blue: 0.260)
    static let green = Color(red: 0.410, green: 0.780, blue: 0.610)
    static let gold = Color(red: 0.860, green: 0.710, blue: 0.360)
    static let red = Color(red: 0.940, green: 0.320, blue: 0.280)
    static let hairline = Color.white.opacity(0.105)
}

#Preview {
    ContentView()
        .environmentObject(OrbitStore())
        .preferredColorScheme(.dark)
}
