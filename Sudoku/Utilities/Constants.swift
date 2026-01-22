import SwiftUI

/// App-wide constants for colors, sizing, and configuration
enum Constants {
    // MARK: - Colors

    enum Colors {
        // Background colors
        static let background = Color.white
        static let gridBackground = Color.white

        // Grid lines
        static let thinLine = Color(hex: "CCCCCC")
        static let thickLine = Color(hex: "333333")

        // Highlighting
        static let highlightRowColBox = Color(hex: "E3F2FD") // Light blue
        static let highlightSelected = Color(hex: "90CAF9") // Medium blue
        static let highlightSameNumber = Color(hex: "BBDEFB") // Pale blue
        static let highlightHintAffected = Color(hex: "C8E6C9") // Light green
        static let highlightHintElimination = Color(hex: "FFECB3") // Light yellow/amber

        // Numbers
        static let givenNumber = Color.black
        static let userNumber = Color(hex: "1565C0") // Dark blue
        static let errorNumber = Color(hex: "E53935") // Red
        static let candidates = Color(hex: "757575") // Gray

        // UI Elements
        static let primaryButton = Color(hex: "1565C0")
        static let secondaryButton = Color(hex: "90CAF9")
        static let toolbarButton = Color(hex: "424242")
        static let toolbarButtonActive = Color(hex: "1565C0")
        static let disabledButton = Color(hex: "BDBDBD")

        // Difficulty colors
        static let easyColor = Color(hex: "4CAF50") // Green
        static let mediumColor = Color(hex: "FF9800") // Orange
        static let hardColor = Color(hex: "F44336") // Red
    }

    // MARK: - Sizing

    enum Sizing {
        // Board dimensions
        static let cellSize: CGFloat = 60
        static let boardPadding: CGFloat = 16
        static let thinLineWidth: CGFloat = 1
        static let thickLineWidth: CGFloat = 3

        // Candidate grid (3x3 within cell)
        static let candidateSize: CGFloat = 18
        static let candidateFontSize: CGFloat = 14

        // Number pad
        static let numberPadButtonSize: CGFloat = 44
        static let numberPadSpacing: CGFloat = 6

        // Toolbar
        static let toolbarButtonSize: CGFloat = 38
        static let toolbarButtonSizeLarge: CGFloat = 56
        static let toolbarSpacing: CGFloat = 20

        // Typography
        static let cellFontSize: CGFloat = 36
        static let headerFontSize: CGFloat = 32
        static let bodyFontSize: CGFloat = 18
        static let captionFontSize: CGFloat = 15

        // Corner radius
        static let buttonCornerRadius: CGFloat = 12
        static let cardCornerRadius: CGFloat = 16
    }

    // MARK: - Animation

    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.15)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.4)
    }

    // MARK: - Game Settings

    enum GameSettings {
        static let maxMistakes = 3
        static let hintPenaltySeconds = 30
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Difficulty Color Extension

extension Difficulty {
    var color: Color {
        switch self {
        case .easy: return Constants.Colors.easyColor
        case .medium: return Constants.Colors.mediumColor
        case .hard: return Constants.Colors.hardColor
        }
    }
}
