import SwiftUI

@main
struct FoldBookApp: App {
    @StateObject private var store = FoldBookStore()
    @StateObject private var purchases = PurchaseManager()
    @AppStorage("foldbook_haptics_enabled") private var hapticsEnabled: Bool = true

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .environmentObject(purchases)
                .preferredColorScheme(.light)
                .onAppear {
                    FBHaptics.enabled = hapticsEnabled
                }
        }
    }
}
