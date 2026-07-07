import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: VetBill?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            entryRow(entry)
                                .listRowBackground(Theme.cardBackground)
                                .contentShape(Rectangle())
                                .onTapGesture { editingEntry = entry }
                        }
                        .onDelete { offsets in store.delete(at: offsets) }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Vetbill")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryEditView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryEditView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(Theme.textSecondary)
            Text("No bill entries yet")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private func entryRow(_ entry: VetBill) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(String(describing: entry.clinicName))
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textPrimary)
            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

struct EntryEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var f1Text: String = ""
    @State private var f2Text: String = ""
    var entry: VetBill?
    var onSave: (VetBill) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Bill") {
                    TextField("Clinicname", text: $f1Text)
                        .accessibilityIdentifier("field1TextField")
                    TextField("Amount", text: $f2Text)
                        .accessibilityIdentifier("field2TextField")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(entry == nil ? "Add Bill" : "Edit Bill")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("saveEntryButton")
                }
            }
            .onAppear {
                if let entry {
                    f1Text = String(describing: entry.clinicName)
                    f2Text = String(describing: entry.amount)
                }
            }
        }
    }

    private func save() {
        let f1Value: String = f1Text
        let f2Value: Double = Double(f2Text) ?? 0
        let result = VetBill(id: entry?.id ?? UUID(), date: entry?.date ?? Date(), clinicName: f1Value, amount: f2Value)
        onSave(result)
        dismiss()
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
