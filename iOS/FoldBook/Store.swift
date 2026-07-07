import Foundation

@MainActor
final class FoldBookStore: ObservableObject {
    @Published private(set) var models: [Model] = []
    @Published private(set) var proEntries: [FBProEntry] = []

    static let freeLimit = 30

    private let fileURL: URL
    private let proFileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("foldbook_models.json")
        self.proFileURL = dir.appendingPathComponent("foldbook_pro.json")
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: proFileURL)
        }
        load()
        if models.isEmpty {
            seedDefaults()
        }
        if proEntries.isEmpty {
            seedProDefaults()
        }
    }

    private func seedDefaults() {
        models = [
            Model(modelName: "Crane", paperType: "Kami 6in", difficulty: "Simple", foldCount: 22),
            Model(modelName: "Kawasaki Rose", paperType: "Foil 8in", difficulty: "Complex", foldCount: 90),
            Model(modelName: "Waterbomb Base", paperType: "Printer Paper", difficulty: "Simple", foldCount: 10)
        ]
        save()
    }

    private func seedProDefaults() {
        proEntries = [
            FBProEntry(sheetName: "Kami Assorted", size: "15cm", weight: "70", pattern: "Solid Mixed"),
            FBProEntry(sheetName: "Tant Paper", size: "24cm", weight: "80", pattern: "Solid Navy")
        ]
        saveProEntries()
    }

    func canAdd(isPro: Bool) -> Bool {
        isPro || models.count < Self.freeLimit
    }

    @discardableResult
    func addModel(modelName: String, paperType: String, difficulty: String, foldCount: Int, isPro: Bool) -> Bool {
        let trimmed = modelName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAdd(isPro: isPro) else { return false }
        let item = Model(modelName: modelName, paperType: paperType, difficulty: difficulty, foldCount: foldCount)
        models.append(item)
        save()
        return true
    }

    func updateModel(_ id: UUID, modelName: String, paperType: String, difficulty: String, foldCount: Int) {
        guard let idx = models.firstIndex(where: { $0.id == id }) else { return }
        models[idx].modelName = modelName
        models[idx].paperType = paperType
        models[idx].difficulty = difficulty
        models[idx].foldCount = foldCount
        save()
    }

    func deleteModel(_ id: UUID) {
        models.removeAll { $0.id == id }
        save()
    }

    func deleteAllData() {
        models = []
        proEntries = []
        seedDefaults()
        seedProDefaults()
    }

    // MARK: - Pro entries

    @discardableResult
    func addProEntry(sheetName: String, size: String, weight: String, pattern: String) -> Bool {
        let entry = FBProEntry(sheetName: sheetName, size: size, weight: weight, pattern: pattern)
        proEntries.append(entry)
        saveProEntries()
        return true
    }

    func deleteProEntry(_ id: UUID) {
        proEntries.removeAll { $0.id == id }
        saveProEntries()
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var items: [Model]
    }
    private struct ProSnapshot: Codable {
        var items: [FBProEntry]
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL), let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            models = decoded.items
        }
        if let data = try? Data(contentsOf: proFileURL), let decoded = try? JSONDecoder().decode(ProSnapshot.self, from: data) {
            proEntries = decoded.items
        }
    }

    private func save() {
        let snapshot = Snapshot(items: models)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func saveProEntries() {
        let snapshot = ProSnapshot(items: proEntries)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: proFileURL, options: .atomic)
    }
}
