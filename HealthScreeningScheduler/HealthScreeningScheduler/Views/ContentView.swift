import SwiftUI

struct ContentView: View {
    @State private var patient = Patient()
    @State private var showResult = false
    @State private var schedule: ScreeningSchedule?

    private let scheduleGenerator = ScheduleGenerator()

    var body: some View {
        NavigationStack {
            VStack {
                if showResult, let schedule = schedule {
                    ResultView(schedule: schedule, onBack: {
                        showResult = false
                    })
                } else {
                    PatientInputView(patient: $patient, onSubmit: {
                        schedule = scheduleGenerator.generateSchedule(for: patient)
                        showResult = true
                    })
                }
            }
            .navigationTitle(showResult ? "検査スケジュール" : "生活習慣病検査スケジューラー")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
