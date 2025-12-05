import SwiftUI

struct LeaderboardDismissWrapper: View {
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        LeaderboardView()
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                        onDismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Main Menu")
                        }
                    }
                }
            }
    }
}
