import SwiftUI

/// Celebration overlay shown when puzzle is completed
struct CompletionView: View {
    let difficulty: Difficulty
    let time: String
    let score: Int
    let hintsUsed: Int
    let mistakes: Int
    let techniquesUsed: Set<TechniqueType>
    let onNewGame: () -> Void
    let onMainMenu: () -> Void

    @State private var showContent = false
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            // Confetti
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }

            // Content card
            VStack(spacing: 24) {
                // Trophy/Star icon
                ZStack {
                    Circle()
                        .fill(difficulty.color.opacity(0.2))
                        .frame(width: 100, height: 100)

                    Image(systemName: starIcon)
                        .font(.system(size: 50))
                        .foregroundColor(difficulty.color)
                }
                .scaleEffect(showContent ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showContent)

                // Title
                VStack(spacing: 8) {
                    Text(titleText)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Constants.Colors.primaryButton)

                    Text("\(difficulty.rawValue) puzzle completed!")
                        .font(.system(size: 16))
                        .foregroundColor(Constants.Colors.candidates)
                }

                // Stats grid
                HStack(spacing: 24) {
                    StatItem(icon: "clock", label: "Time", value: time)
                    StatItem(icon: "star.fill", label: "Score", value: "\(score)")
                    StatItem(icon: "lightbulb", label: "Hints", value: "\(hintsUsed)")
                }
                .padding(.vertical, 8)

                // Techniques used section
                if !techniquesUsed.isEmpty {
                    VStack(spacing: 8) {
                        Text("Techniques Used")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Constants.Colors.candidates)

                        FlowLayout(spacing: 8) {
                            ForEach(Array(techniquesUsed).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { technique in
                                TechniqueBadge(technique: technique)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Performance message
                Text(performanceMessage)
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.toolbarButton)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Buttons
                VStack(spacing: 12) {
                    Button(action: onNewGame) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New Game")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Constants.Colors.primaryButton)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button(action: onMainMenu) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Main Menu")
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Constants.Colors.toolbarButton)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Constants.Colors.highlightRowColBox)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
            }
            .padding(24)
            .background(Constants.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(radius: 30)
            .padding(24)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 50)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                showContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showConfetti = true
            }
        }
    }

    private var starIcon: String {
        if hintsUsed == 0 && mistakes == 0 {
            return "star.circle.fill"
        } else if hintsUsed <= 2 && mistakes <= 1 {
            return "trophy.fill"
        } else {
            return "checkmark.circle.fill"
        }
    }

    private var titleText: String {
        if hintsUsed == 0 && mistakes == 0 {
            return "Perfect!"
        } else if hintsUsed <= 2 && mistakes <= 1 {
            return "Great Job!"
        } else {
            return "Well Done!"
        }
    }

    private var performanceMessage: String {
        if hintsUsed == 0 && mistakes == 0 {
            return "Flawless victory! No hints, no mistakes."
        } else if hintsUsed == 0 {
            return "Solved without any hints!"
        } else if mistakes == 0 {
            return "Clean solve with no mistakes!"
        } else {
            return "Keep practicing to improve your skills!"
        }
    }
}

/// Individual stat item
struct StatItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Constants.Colors.primaryButton)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Constants.Colors.toolbarButton)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.candidates)
        }
    }
}

/// Badge showing a technique name
struct TechniqueBadge: View {
    let technique: TechniqueType

    var body: some View {
        Text(technique.rawValue)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(technique.difficulty.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(technique.difficulty.color.opacity(0.15))
            .clipShape(Capsule())
    }
}

/// Simple flow layout for wrapping badges
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)

        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: totalWidth, height: totalHeight), positions)
    }
}

#Preview {
    CompletionView(
        difficulty: .medium,
        time: "12:34",
        score: 850,
        hintsUsed: 2,
        mistakes: 1,
        techniquesUsed: [.hiddenSingle, .nakedPair, .pointingPair],
        onNewGame: {},
        onMainMenu: {}
    )
}
