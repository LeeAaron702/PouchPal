//
//  Theme.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import SwiftUI

// MARK: - Fallback Colors (programmatic colors used throughout the app)
extension Color {
    static let ppBackgroundFallback = Color(UIColor.systemBackground)
    static let ppCardBackgroundFallback = Color(UIColor.secondarySystemBackground)
    static let ppPrimaryFallback = Color(red: 0.35, green: 0.55, blue: 0.95) // Soft blue
    static let ppSecondaryFallback = Color(red: 0.45, green: 0.75, blue: 0.65) // Teal
    static let ppAccentFallback = Color(red: 0.95, green: 0.65, blue: 0.35) // Warm orange
    static let ppSuccessFallback = Color(red: 0.35, green: 0.75, blue: 0.45) // Green
    static let ppWarningFallback = Color(red: 0.95, green: 0.75, blue: 0.30) // Amber
    static let ppDangerFallback = Color(red: 0.90, green: 0.40, blue: 0.40) // Red
}

// MARK: - Typography
struct PPFont {
    static func largeTitle(_ weight: Font.Weight = .bold) -> Font {
        .system(size: 72, weight: weight, design: .rounded)
    }
    
    static func title(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: 28, weight: weight, design: .rounded)
    }
    
    static func headline(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: 18, weight: weight, design: .rounded)
    }
    
    static func body(_ weight: Font.Weight = .regular) -> Font {
        .system(size: 16, weight: weight, design: .rounded)
    }
    
    static func caption(_ weight: Font.Weight = .medium) -> Font {
        .system(size: 14, weight: weight, design: .rounded)
    }
    
    static func small(_ weight: Font.Weight = .regular) -> Font {
        .system(size: 12, weight: weight, design: .rounded)
    }
}

// MARK: - Haptics
struct PPHaptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Animation Constants
struct PPAnimation {
    static let quick = Animation.easeOut(duration: 0.15)
    static let standard = Animation.easeInOut(duration: 0.25)
    static let smooth = Animation.spring(response: 0.35, dampingFraction: 0.7)
    static let bounce = Animation.spring(response: 0.4, dampingFraction: 0.6)
}

// MARK: - Spacing
struct PPSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct PPRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 100
}
