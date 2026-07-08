import Foundation

struct Model: Identifiable, Codable, Equatable {
    let id: UUID
    var modelName: String
    var paperType: String
    var difficulty: String
    var foldCount: Int
    var createdDate: Date

    init(id: UUID = UUID(), modelName: String = "Crane", paperType: String = "Kami 6in", difficulty: String = "Intermediate", foldCount: Int = 24, createdDate: Date = Date()) {
        self.id = id
        self.modelName = modelName
        self.paperType = paperType
        self.difficulty = difficulty
        self.foldCount = foldCount
        self.createdDate = createdDate
    }
}

/// Pro bonus feature entry: Paper Stash Tracker.
struct FBProEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var sheetName: String
    var size: String
    var weight: String
    var pattern: String
    var createdDate: Date

    init(id: UUID = UUID(), sheetName: String = "Origamido Vellum", size: String = "15cm", weight: String = "90", pattern: String = "Solid Red", createdDate: Date = Date()) {
        self.id = id
        self.sheetName = sheetName
        self.size = size
        self.weight = weight
        self.pattern = pattern
        self.createdDate = createdDate
    }
}

enum FBDifficultyOption {
    static let all = ["Simple", "Intermediate", "Complex", "Master"]
}
