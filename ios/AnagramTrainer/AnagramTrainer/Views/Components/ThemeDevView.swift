import SwiftUI

struct ThemeDevView: View {
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Base Colors")) {
                    ColorPicker("Light Base (Soft Pink)", selection: $theme.lightBaseColor)
                    ColorPicker("Dark Base (Deep Plum)", selection: $theme.darkBaseColor)
                }
                
                Section(header: Text("Actions")) {
                    Button("Log Hex Codes to Console") {
                        theme.logBaseColors()
                    }
                    
                    Button("Reset to Defaults") {
                        theme.lightBaseColor = Color(red: 0.95, green: 0.4, blue: 0.6)
                        theme.darkBaseColor = Color(red: 0.25, green: 0.12, blue: 0.18)
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("Preview")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Light Mode")
                                .font(.caption)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.backgroundGradient(for: .light))
                                .frame(height: 60)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Dark Mode")
                                .font(.caption)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.backgroundGradient(for: .dark))
                                .frame(height: 60)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Theme Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ThemeDevView()
}
