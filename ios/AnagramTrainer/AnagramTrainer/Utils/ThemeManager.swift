import SwiftUI
import UIKit
import Combine

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var lightBaseColor: Color = Color(red: 0.95, green: 0.4, blue: 0.6) // Soft Pink
    @Published var darkBaseColor: Color = Color(red: 0.25, green: 0.12, blue: 0.18) // Deep Plum
    
    // Derived light colors
    var vibrantPink: Color {
        // Approximate the vibrant pink from hardcoded values: Color(red: 1.0, green: 0.3, blue: 0.5)
        // We calculate it relative to the base if we want dynamicism, but for now we can just store or derive it.
        // Let's derive it to make experiments fun.
        adjustColor(lightBaseColor, saturation: 1.1, brightness: 1.1)
    }
    
    var purplePink: Color {
        // Approximate Color(red: 0.8, green: 0.3, blue: 0.7)
        adjustColor(lightBaseColor, hueShift: 0.1, saturation: 0.9)
    }
    
    var letterColorLight: Color {
        // Color(red: 0.87, green: 0.45, blue: 0.62)
        adjustColor(lightBaseColor, brightness: 0.9)
    }
    
    // Derived dark colors
    var darkBurgundy: Color {
        // Color(red: 0.2, green: 0.1, blue: 0.15)
        adjustColor(darkBaseColor, brightness: 0.8)
    }
    
    var darkPurple: Color {
        // Color(red: 0.18, green: 0.08, blue: 0.2)
        adjustColor(darkBaseColor, hueShift: 0.05, saturation: 1.1)
    }
    
    var letterColorDark: Color {
        // Color(red: 0.25, green: 0.1, blue: 0.18) 
        adjustColor(darkBaseColor, brightness: 0.85)
    }
    
    func backgroundGradient(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [darkBurgundy, darkBaseColor, darkPurple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [vibrantPink, lightBaseColor, purplePink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    func letterColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? letterColorDark : letterColorLight
    }
    
    func logBaseColors() {
        print("--- Theme Manager Colors ---")
        print("Light Base: \(lightBaseColor.description)")
        print("Dark Base: \(darkBaseColor.description)")
        
        // Convert to components for easier permanent implementation
        let uiLight = UIColor(lightBaseColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiLight.getRed(&r, green: &g, blue: &b, alpha: &a)
        print("Light RGB: \(r), \(g), \(b)")

        let uiDark = UIColor(darkBaseColor)
        uiDark.getRed(&r, green: &g, blue: &b, alpha: &a)
        print("Dark RGB: \(r), \(g), \(b)")
    }
    
    private func adjustColor(_ color: Color, hueShift: Double = 0, saturation: Double = 1.0, brightness: Double = 1.0) -> Color {
        let uiColor = UIColor(color)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        return Color(hue: Double(h) + hueShift,
                     saturation: Double(s) * saturation,
                     brightness: Double(b) * brightness,
                     opacity: Double(a))
    }
}
