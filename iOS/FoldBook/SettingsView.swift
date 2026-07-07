import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: FoldBookStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("foldbook_haptics_enabled") private var hapticsEnabled: Bool = true
    @AppStorage("foldbook_show_notes") private var showNotes: Bool = true

    @State private var showingDeleteConfirm = false
    @State private var showingPaywall = false
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                FBTheme.backdrop.ignoresSafeArea()

                Form {
                    Section {
                        if purchases.isPro {
                            HStack {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(FBTheme.accent)
                                Text("Fold Book Pro active")
                                    .foregroundStyle(FBTheme.ink)
                            }
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill").foregroundStyle(FBTheme.accent2)
                                    Text("Unlock Pro")
                                        .foregroundStyle(FBTheme.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(FBTheme.inkFaded)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("settingsUnlockProButton")
                        }
                    }
                    .listRowBackground(FBTheme.card)

                    if purchases.isPro {
                        Section("Paper Stash Tracker") {
                            Text("Track your paper stash sorted by size, weight, and pattern.")
                                .font(.caption)
                                .foregroundStyle(FBTheme.inkFaded)
                            ForEach(store.proEntries) { p in
                                HStack {
                                    Text(p.sheetName)
                                        .foregroundStyle(FBTheme.ink)
                                    Spacer()
                                    Text(p.size)
                                        .font(.caption)
                                        .foregroundStyle(FBTheme.accent)
                                }
                            }
                            .onDelete { offsets in
                                for idx in offsets { store.deleteProEntry(store.proEntries[idx].id) }
                            }
                        }
                        .listRowBackground(FBTheme.card)
                    }

                    Section("Preferences") {
                        Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { _, newValue in
                                FBHaptics.enabled = newValue
                            }
                        Toggle("Show Notes", isOn: $showNotes)
                    }
                    .listRowBackground(FBTheme.card)

                    Section {
                        Button {
                            if store.canAdd(isPro: purchases.isPro) {
                                showingAdd = true
                            } else {
                                showingPaywall = true
                            }
                        } label: {
                            Label("Add Entry", systemImage: "plus")
                        }
                        .accessibilityIdentifier("settingsAddModelButton")
                    }
                    .listRowBackground(FBTheme.card)

                    Section {
                        Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/foldbook-app/privacy.html")!)
                        Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/foldbook-app/terms.html")!)
                        Button("Restore Purchases") {
                            Task { await purchases.restore() }
                        }
                    }
                    .listRowBackground(FBTheme.card)

                    Section {
                        Button("Delete All Data", role: .destructive) {
                            showingDeleteConfirm = true
                        }
                    }
                    .listRowBackground(FBTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete all data? This cannot be undone.", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) {
                    store.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingAdd) {
                ModelFormView(mode: .add)
            }
        }
    }
}
