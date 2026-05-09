import Foundation

@MainActor
final class NoteStore: ObservableObject {
    @Published private(set) var notes: [PreviewNote] = []

    private let storageKey = "ai.axint.preview-notes.items"

    init() {
        load()
        if notes.isEmpty {
            seed()
        }
    }

    var pinnedNotes: [PreviewNote] {
        notes
            .filter(\.isPinned)
            .sorted { $0.createdAt > $1.createdAt }
    }

    var openNotes: [PreviewNote] {
        notes
            .filter { !$0.isDone }
            .sorted { lhs, rhs in
                if lhs.isPinned != rhs.isPinned { return lhs.isPinned }
                return lhs.createdAt > rhs.createdAt
            }
    }

    func add(title: String, body: String, category: NoteCategory) {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTitle.isEmpty else { return }

        notes.insert(
            PreviewNote(
                title: cleanedTitle,
                body: cleanedBody.isEmpty ? "Captured from Cloud Preview." : cleanedBody,
                category: category,
                isPinned: notes.isEmpty
            ),
            at: 0
        )
        save()
    }

    func addDemoNote() {
        add(
            title: "Cloud Preview tapped this",
            body: "This note was created by a button tap, which makes it useful for browser-based runner checks.",
            category: .task
        )
    }

    func togglePinned(_ note: PreviewNote) {
        update(note) { $0.isPinned.toggle() }
    }

    func toggleDone(_ note: PreviewNote) {
        update(note) { $0.isDone.toggle() }
    }

    func clearCompleted() {
        notes.removeAll(where: \.isDone)
        save()
    }

    func resetDemoData() {
        notes.removeAll()
        seed()
    }

    private func update(_ note: PreviewNote, mutate: (inout PreviewNote) -> Void) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        mutate(&notes[index])
        save()
    }

    private func seed() {
        notes = [
            PreviewNote(
                title: "Test Cloud Preview",
                body: "Open the app, tap Compose, save a note, then confirm it appears in Today.",
                category: .task,
                isPinned: true
            ),
            PreviewNote(
                title: "Ship a real preview",
                body: "This fixture makes the browser room prove navigation, buttons, text input, and local persistence.",
                category: .idea
            ),
            PreviewNote(
                title: "Runner handoff",
                body: "A Mac runner can build this repo and stream simulator state back to Axint Cloud Preview.",
                category: .meeting
            ),
        ]
        save()
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([PreviewNote].self, from: data)
        else {
            return
        }
        notes = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(notes) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
