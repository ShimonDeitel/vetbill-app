import Foundation

struct VetBill: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var clinicName: String
    var amount: Double

    init(id: UUID = UUID(), date: Date = Date(), clinicName: String, amount: Double) {
        self.id = id
        self.date = date
        self.clinicName = clinicName
        self.amount = amount
    }
}

struct AppSettings: Codable, Equatable {
    var remindersEnabled: Bool = true
    var iCloudSyncEnabled: Bool = false
    var hapticsEnabled: Bool = true
}
