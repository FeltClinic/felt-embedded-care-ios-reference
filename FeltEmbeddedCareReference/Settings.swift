import SwiftUI
import FeltEmbeddedCare

/// SDK key setup
struct Settings: View {

    @Binding var sdkKey: String

    @State private var editingSDKKey = ""
    @State private var showErrorAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                TextField("SDK Key", text: $editingSDKKey, prompt: Text("Enter your SDK key"))
                    .textFieldStyle(.roundedBorder)

                Button("Confirm") {
                    Task {
                        do {
                            try await initializeEmbeddedCare(sdkKey: editingSDKKey)
                            sdkKey = editingSDKKey
                            dismiss()
                        } catch {
                            showErrorAlert = true
                        }
                    }
                }
                .disabled(editingSDKKey.isEmpty)
            }
            .padding()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button("Cancel", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                    .disabled(sdkKey.isEmpty)
                }
            }
        }
        .onAppear {
            editingSDKKey = sdkKey
        }
        .alert("Invalid SDK Key", isPresented: $showErrorAlert) {}
    }

}

#Preview {
    @Previewable @State var sdkKey = ""
    Settings(sdkKey: $sdkKey)
}
