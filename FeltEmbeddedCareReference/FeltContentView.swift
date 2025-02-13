import SwiftUI
import FeltEmbeddedCare

/// Felt content examples
struct FeltContentView: View {

    @State private var triageHeight: CGFloat?
    @State private var dismissableHeight: CGFloat?
    @State private var selectedTab = TabItem.components
    @State private var presentedExperience: FullScreenExperience?

    enum TabItem: Hashable {
        case components
        case fullScreen
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Examples of `Component`s that can be integrated alongside your app's native content
            Tab("Components", systemImage: "menucard", value: TabItem.components) {
                ScrollView {
                    VStack {
                        Component(experience: .dismissableCallToAction, custom: [:]) {
                            dismissableHeight = $0
                        }
                        // Components load their content asynchronously.
                        // Here, we smoothly animate intrinsic size changes.
                        .animation(.default, value: dismissableHeight)
                        .padding()

                        // Some components require setting custom data in order to properly render.
                        // This is dependent on each client implementation.
                        Component(experience: .triagedCallToAction, custom: ["triageRecommendationLevel": "CALL_DOCTOR_NOW"]) {
                            triageHeight = $0
                        }
                        .animation(.default, value: triageHeight)
                        .padding()
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            // An example of a `FullScreenView` inside a tab
            Tab("Full Screen", systemImage: "display", value: .fullScreen) {
                FullScreenView(experience: .valuePropositionScreen)
            }
        }
        .toolbar {
            // An example of explicitly presenting an experience
            ToolbarItem(placement: .topBarTrailing) {
                Button("Present Experience") {
                    EmbeddedCare.shared.presentExperience(.pricingScreen)
                }
            }

            // Send a local notification to test notification handling
            ToolbarItem(placement: .topBarTrailing) {
                Button("Notification") {
                    Task {
                        do {
                            guard try await UNUserNotificationCenter.current().requestAuthorization(options: .alert) else { return }

                            let content = UNMutableNotificationContent()
                            content.title = "Felt Notification"
                            content.body = "This is a test notification"
                            content.userInfo = ["felt-route": "/pricing"]

                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)

                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            try await UNUserNotificationCenter.current().add(request)
                        } catch {
                            print("Failed to send test notification: \(error)")
                        }
                    }
                }
            }
        }
        // URL handling
        .onOpenURL { url in
            _ = EmbeddedCare.shared.handleURL(url)
        }
    }

}
