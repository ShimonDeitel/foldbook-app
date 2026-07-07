import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            ModelListView()
                .tabItem { Label("Home", systemImage: "list.bullet.clipboard") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(FBTheme.accent)
    }
}

struct ModelListView: View {
    @EnvironmentObject private var store: FoldBookStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var editingItem: Model?

    var body: some View {
        NavigationStack {
            ZStack {
                FBTheme.backdrop.ignoresSafeArea()
                if store.models.isEmpty {
                    ContentUnavailableView("No Models Yet", systemImage: "square.stack.3d.up", description: Text("Tap + to log your first entry."))
                } else {
                    List {
                        ForEach(store.models) { item in
                            ModelRow(item: item)
                                .listRowBackground(FBTheme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        store.deleteModel(item.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Fold Book")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addModelButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                ModelFormView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                ModelFormView(mode: .edit(item))
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct ModelRow: View {
    let item: Model

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.modelName)
                .font(FBTheme.headlineFont)
                .foregroundStyle(FBTheme.ink)
            Text(String(describing: item.paperType))
                .font(.caption)
                .foregroundStyle(FBTheme.inkFaded)
        }
        .padding(.vertical, 4)
    }
}

enum ModelFormMode: Identifiable {
    case add
    case edit(Model)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct ModelFormView: View {
    @EnvironmentObject private var store: FoldBookStore
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    let mode: ModelFormMode

    @State private var draftModelName: String = ""
    @State private var draftPaperType: String = ""
    @State private var draftDifficulty: String = ""
    @State private var draftFoldCount: Int = 24

    var body: some View {
        NavigationStack {
            ZStack {
                FBTheme.backdrop.ignoresSafeArea()
                Form {
                    Section {
                TextField("Model", text: $draftModelName)
                    .accessibilityIdentifier("modelNameField")
                TextField("Paper Type", text: $draftPaperType)
                    .accessibilityIdentifier("paperTypeField")
                Picker("Difficulty", selection: $draftDifficulty) {
                    ForEach(FBDifficultyOption.all, id: \.self) { Text($0) }
                }
                TextField("Fold Steps", value: $draftFoldCount, format: .number)
                    .keyboardType(.numberPad)
                    .accessibilityIdentifier("foldCountField")
                    }
                    .listRowBackground(FBTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("modelSaveButton")
                }
            }
            .onAppear { loadIfEditing() }
            .dismissKeyboardOnTap()
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftModelName = item.modelName
        draftPaperType = item.paperType
        draftDifficulty = item.difficulty
        draftFoldCount = item.foldCount
        } else {
        draftModelName = ""
        draftPaperType = ""
        draftDifficulty = ""
        draftFoldCount = 24
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.addModel(draftModelName, draftPaperType, draftDifficulty, draftFoldCount, isPro: purchases.isPro)
        case .edit(let item):
            store.updateModel(item.id, draftModelName, draftPaperType, draftDifficulty, draftFoldCount)
        }
        FBHaptics.success()
        dismiss()
    }
}
