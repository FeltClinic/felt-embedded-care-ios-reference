import SwiftUI
import FeltEmbeddedCare

@main
struct FeltEmbeddedCareReferenceApp: App {

    @AppStorage("sdkKey") var sdkKey = ""

    @State var hasLaunched = false
    @State var showSettings = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Group {
                    if hasLaunched {
                        // Only show Felt content if the `globalRollout` feature gate is enabled
                        if EmbeddedCare.shared.checkFeatureGate(.globalRollout) {
                            FeltContentView()
                        } else {
                            Text("Felt global rollout is not enabled")
                        }
                    } else {
                        ProgressView()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Settings", systemImage: "gear") {
                            showSettings = true
                        }
                    }
                }
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            }
            // Refresh content on sdk key change
            .tag(sdkKey)
            .task {
                // Initialize with the stored sdk key at launch if present
                if !hasLaunched && !sdkKey.isEmpty {
                    do {
                        try await initializeEmbeddedCare(sdkKey: sdkKey)
                    } catch {
                        print("Failed to initialize embedded care")
                        sdkKey = ""
                    }
                }

                hasLaunched = true

                // Show settings if there is no set sdk key
                if sdkKey.isEmpty {
                    showSettings = true
                }
            }
            .fullScreenCover(isPresented: $showSettings) {
                Settings(sdkKey: $sdkKey)
            }
        }
    }

}

@MainActor
func initializeEmbeddedCare(sdkKey: String) async throws {
    try await EmbeddedCare.shared.initialize(sdkKey: sdkKey)
    // Set a placeholder account
    EmbeddedCare.shared.account = Account(
        id: "test-account",
        selectedPatient: Patient(
            id: "test-patient",
            firstName: "Bob",
            lastName: "Smith"
        )
    )
}
