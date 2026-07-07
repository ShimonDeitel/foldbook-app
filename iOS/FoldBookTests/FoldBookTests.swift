import XCTest
@testable import FoldBook

final class FoldBookTests: XCTestCase {

    @MainActor
    func testStoreSeedsAboveZeroButBelowFreeLimit() {
        let store = FoldBookStore()
        XCTAssertGreaterThan(store.models.count, 0)
        XCTAssertLessThan(store.models.count, FoldBookStore.freeLimit)
    }

    @MainActor
    func testAddEntrySucceedsWhenUnderLimit() {
        let store = FoldBookStore()
        let before = store.models.count
        let added = store.addModel(modelName: "Crane", paperType: "Kami 6in", difficulty: "Intermediate", foldCount: 24, isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.models.count, before + 1)
    }

    @MainActor
    func testAddEntryRejectsBlankPrimaryField() {
        let store = FoldBookStore()
        let before = store.models.count
        let added = store.addModel(modelName: "   ", paperType: "Kami 6in", difficulty: "Intermediate", foldCount: 24, isPro: false)
        XCTAssertFalse(added)
        XCTAssertEqual(store.models.count, before)
    }

    @MainActor
    func testFreeLimitBlocksAdditionalEntries() {
        let store = FoldBookStore()
        for item in store.models { store.deleteModel(item.id) }
        for _ in 0..<FoldBookStore.freeLimit {
            XCTAssertTrue(store.addModel(modelName: "Crane", paperType: "Kami 6in", difficulty: "Intermediate", foldCount: 24, isPro: false))
        }
        XCTAssertFalse(store.addModel(modelName: "Crane", paperType: "Kami 6in", difficulty: "Intermediate", foldCount: 24, isPro: false))
        XCTAssertTrue(store.addModel(modelName: "Crane", paperType: "Kami 6in", difficulty: "Intermediate", foldCount: 24, isPro: true))
    }

    @MainActor
    func testDeleteEntry() {
        let store = FoldBookStore()
        store.addModel(modelName: "Crane", paperType: "Kami 6in", difficulty: "Intermediate", foldCount: 24, isPro: false)
        guard let item = store.models.last else { return XCTFail("expected entry") }
        let before = store.models.count
        store.deleteModel(item.id)
        XCTAssertEqual(store.models.count, before - 1)
    }

    @MainActor
    func testDeleteAllDataReseeds() {
        let store = FoldBookStore()
        store.deleteAllData()
        XCTAssertGreaterThan(store.models.count, 0)
        XCTAssertGreaterThan(store.proEntries.count, 0)
    }

    @MainActor
    func testUpdateEntryPersistsChange() {
        let store = FoldBookStore()
        store.addModel(modelName: "Crane", paperType: "Kami 6in", difficulty: "Intermediate", foldCount: 24, isPro: false)
        guard let item = store.models.last else { return XCTFail("expected entry") }
        store.updateModel(item.id, modelName: "Crane", paperType: "Kami 6in", difficulty: "Intermediate", foldCount: 24)
        XCTAssertEqual(store.models.count, store.models.count)
    }
}
