import SwiftUI
import UIKit
import Combine

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    // Default base colors to revert to
    static let defaultLightBase: Color = Color(red: 0.95, green: 0.4, blue: 0.6)
    static let defaultDarkBase: Color = Color(red: 0.25, green: 0.12, blue: 0.18)
    
    @Published var lightBaseColor: Color = defaultLightBase
    @Published var darkBaseColor: Color = defaultDarkBase
    
    private var resetTask: Task<Void, Error>? = nil
    
    func setBaseColor(_ color: Color, for scheme: ColorScheme, animated: Bool = true) {
        cancelPendingReset()
        
        let update = {
            if scheme == .dark {
                self.darkBaseColor = color
            } else {
                self.lightBaseColor = color
            }
        }
        
        if animated {
            withAnimation(.easeInOut(duration: 0.4)) {
                update()
            }
        } else {
            update()
        }
    }
    
    func cancelPendingReset() {
        resetTask?.cancel()
        resetTask = nil
    }
    
    func resetToDefaults(animated: Bool = true, delay: Double = 0.0) {
        cancelPendingReset()
        
        if delay > 0 {
            resetTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                if !Task.isCancelled {
                    await MainActor.run {
                        self.performReset(animated: animated)
                    }
                }
            }
        } else {
            performReset(animated: animated)
        }
    }
    
    private func performReset(animated: Bool) {
        let update = {
            self.lightBaseColor = ThemeManager.defaultLightBase
            self.darkBaseColor = ThemeManager.defaultDarkBase
        }
        
        if animated {
            withAnimation(.easeInOut(duration: 0.4)) {
                update()
            }
        } else {
            update()
        }
    }
    
    // Derived light colors
    func vibrantPink(for base: Color) -> Color {
        adjustColor(base, saturation: 1.1, brightness: 1.1)
    }
    
    func purplePink(for base: Color) -> Color {
        adjustColor(base, hueShift: 0.1, saturation: 0.9)
    }
    
    func letterColorLight(for base: Color) -> Color {
        adjustColor(base, brightness: 0.9)
    }
    
    // Derived dark colors
    func darkBurgundy(for base: Color) -> Color {
        adjustColor(base, brightness: 0.8)
    }
    
    func darkPurple(for base: Color) -> Color {
        adjustColor(base, hueShift: 0.05, saturation: 1.1)
    }
    
    func letterColorDark(for base: Color) -> Color {
        adjustColor(base, brightness: 0.85)
    }
    
    func backgroundGradient(for base: Color, colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [darkBurgundy(for: base), base, darkPurple(for: base)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [vibrantPink(for: base), base, purplePink(for: base)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    func letterColor(for base: Color, colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? letterColorDark(for: base) : letterColorLight(for: base)
    }
    
    func logBaseColors(light: Color, dark: Color) {
        print("--- Theme Manager Colors ---")
        print("Light Base: \(light.description)")
        print("Dark Base: \(dark.description)")
        
        let uiLight = UIColor(light)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiLight.getRed(&r, green: &g, blue: &b, alpha: &a)
        print("Light RGB: \(r), \(g), \(b)")

        let uiDark = UIColor(dark)
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

// MARK: - Environment Support

struct ThemeBaseColorKey: EnvironmentKey {
    static let defaultValue: Color = ThemeManager.defaultLightBase
}

struct ThemeDarkBaseColorKey: EnvironmentKey {
    static let defaultValue: Color = ThemeManager.defaultDarkBase
}

extension EnvironmentValues {
    var themeBaseColor: Color {
        get { self[ThemeBaseColorKey.self] }
        set { self[ThemeBaseColorKey.self] = newValue }
    }
    
    var themeDarkBaseColor: Color {
        get { self[ThemeDarkBaseColorKey.self] }
        set { self[ThemeDarkBaseColorKey.self] = newValue }
    }
}
