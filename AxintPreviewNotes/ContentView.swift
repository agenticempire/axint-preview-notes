import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: NoteStore

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max")
                }
                .accessibilityIdentifier("tab.today")

            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                .accessibilityIdentifier("tab.notes")

            ComposeView()
                .tabItem {
                    Label("Compose", systemImage: "square.and.pencil")
                }
                .accessibilityIdentifier("tab.compose")
        }
        .tint(.orange)
    }
}

private struct TodayView: View {
    @EnvironmentObject private var store: NoteStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HeaderCard()

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                        spacing: 12
                    ) {
                        StatCard(value: "\(store.openNotes.count)", label: "Open")
                        StatCard(value: "\(store.pinnedNotes.count)", label: "Pinned")
                        StatCard(value: "\(store.notes.filter(\.isDone).count)", label: "Done")
                    }
                    .accessibilityIdentifier("today.stats")

                    Button {
                        store.addDemoNote()
                    } label: {
                        Label("Add Demo Note", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("button.add-demo-note")

                    SectionTitle("Pinned")

                    if store.pinnedNotes.isEmpty {
                        EmptyState(title: "No pinned notes", subtitle: "Pin something from the Notes tab.")
                    } else {
                        ForEach(store.pinnedNotes) { note in
                            NoteRow(note: note)
                        }
                    }
                }
                .padding(20)
            }
            .background(AppBackground())
            .navigationTitle("Preview Notes")
            .toolbar {
                Button("Reset") {
                    store.resetDemoData()
                }
                .accessibilityIdentifier("button.reset-demo")
            }
        }
    }
}

private struct NotesView: View {
    @EnvironmentObject private var store: NoteStore
    @State private var search = ""

    private var filteredNotes: [PreviewNote] {
        guard !search.isEmpty else { return store.notes }
        return store.notes.filter {
            $0.title.localizedCaseInsensitiveContains(search) ||
            $0.body.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredNotes) { note in
                    VStack(alignment: .leading, spacing: 12) {
                        NoteRow(note: note)

                        HStack {
                            Button(note.isPinned ? "Unpin" : "Pin") {
                                store.togglePinned(note)
                            }
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier("button.pin.\(note.id.uuidString)")

                            Button(note.isDone ? "Reopen" : "Done") {
                                store.toggleDone(note)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(note.isDone ? .gray : .green)
                            .accessibilityIdentifier("button.done.\(note.id.uuidString)")
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle("All Notes")
            .searchable(text: $search, prompt: "Search notes")
            .accessibilityIdentifier("field.search-notes")
            .toolbar {
                Button("Clear Done") {
                    store.clearCompleted()
                }
                .accessibilityIdentifier("button.clear-done")
            }
        }
    }
}

private struct ComposeView: View {
    @EnvironmentObject private var store: NoteStore
    @State private var title = ""
    @State private var bodyText = ""
    @State private var category: NoteCategory = .idea
    @State private var savedMessage = "Ready"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Capture something useful.")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)

                    TextField("Title", text: $title)
                        .textFieldStyle(PreviewFieldStyle())
                        .accessibilityIdentifier("field.note-title")

                    TextField("Body", text: $bodyText, axis: .vertical)
                        .lineLimit(5, reservesSpace: true)
                        .textFieldStyle(PreviewFieldStyle())
                        .accessibilityIdentifier("field.note-body")

                    Picker("Category", selection: $category) {
                        ForEach(NoteCategory.allCases) { option in
                            Label(option.rawValue, systemImage: option.symbol)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("picker.note-category")

                    Button {
                        store.add(title: title, body: bodyText, category: category)
                        savedMessage = title.isEmpty ? "Add a title first" : "Saved: \(title)"
                        if !title.isEmpty {
                            title = ""
                            bodyText = ""
                            category = .idea
                        }
                    } label: {
                        Label("Save Note", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("button.save-note")

                    Button {
                        title = "Cloud Preview Note"
                        bodyText = "Typed by the demo shortcut so browser automation has predictable text to verify."
                        category = .task
                        savedMessage = "Draft filled"
                    } label: {
                        Label("Fill Demo Draft", systemImage: "wand.and.stars")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityIdentifier("button.fill-demo-draft")

                    Text(savedMessage)
                        .font(.headline.monospaced())
                        .foregroundStyle(.orange)
                        .padding(.top, 8)
                        .accessibilityIdentifier("text.saved-message")
                }
                .padding(20)
            }
            .background(AppBackground())
            .navigationTitle("Compose")
        }
    }
}

private struct HeaderCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cloud Preview Fixture")
                .font(.caption.monospaced().weight(.bold))
                .foregroundStyle(.orange)
                .textCase(.uppercase)

            Text("A real iOS app that proves taps, text entry, navigation, and persistence.")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text("Use this repo to test Axint Cloud Preview from a browser while Xcode runs on a Mac runner.")
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .accessibilityIdentifier("card.header")
    }
}

private struct NoteRow: View {
    let note: PreviewNote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(note.category.rawValue, systemImage: note.category.symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)

                Spacer()

                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundStyle(.orange)
                }

                if note.isDone {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                }
            }

            Text(note.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(note.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.orange.opacity(0.18), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("note-row.\(note.title)")
    }
}

private struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title.bold())
                .foregroundStyle(.primary)

            Text(label)
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct SectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.headline.monospaced().weight(.bold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
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
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(.background.opacity(0.7), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.orange.opacity(0.16),
                Color(.systemBackground),
                Color.blue.opacity(0.10),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 15)
            .padding(.horizontal, 18)
            .foregroundStyle(.white)
            .background(.orange, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.smooth(duration: 0.18), value: configuration.isPressed)
    }
}

private struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .foregroundStyle(.orange)
            .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.smooth(duration: 0.18), value: configuration.isPressed)
    }
}

private struct PreviewFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.orange.opacity(0.22), lineWidth: 1)
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(NoteStore())
}
