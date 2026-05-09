import Foundation

struct PreviewNote: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var body: String
    var category: NoteCategory
    var isPinned: Bool
    var isDone: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        category: NoteCategory = .idea,
        isPinned: Bool = false,
        isDone: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.category = category
        self.isPinned = isPinned
        self.isDone = isDone
        self.createdAt = createdAt
    }
}

enum NoteCategory: String, CaseIterable, Codable, Identifiable {
    case idea = "Idea"
    case task = "Task"
    case meeting = "Meeting"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .idea: "sparkles"
        case .task: "checkmark.circle"
        case .meeting: "person.2"
        }
    }
}
