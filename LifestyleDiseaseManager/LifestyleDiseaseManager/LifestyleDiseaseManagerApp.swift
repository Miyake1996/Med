import SwiftUI
import SwiftData

@main
struct LifestyleDiseaseManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Patient.self, ExaminationRecord.self])
    }
}
