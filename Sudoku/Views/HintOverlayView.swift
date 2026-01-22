import SwiftUI

/// Overlay that shows technique hints with explanations
struct HintOverlayView: View {
    let hint: TechniqueHint
    let onApply: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(hint.technique.rawValue)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Constants.Colors.primaryButton)

                        Text(hint.technique.category.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Constants.Colors.candidates)
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Constants.Colors.candidates)
                    }
                }

                Divider()

                // Explanation
                Text(hint.explanation)
                    .font(.system(size: 16))
                    .foregroundColor(Constants.Colors.toolbarButton)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                // Affected cells info
                if !hint.affectedCells.isEmpty {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Constants.Colors.highlightHintAffected)
                            .frame(width: 12, height: 12)
                        Text("Green cells: where to look")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.candidates)

                        if !hint.eliminationCells.isEmpty {
                            Circle()
                                .fill(Constants.Colors.highlightHintElimination)
                                .frame(width: 12, height: 12)
                            Text("Yellow cells: eliminations")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.candidates)
                        }

                        Spacer()
                    }
                }

                // Value to place
                if hint.candidates.count == 1, let value = hint.candidates.first {
                    HStack {
                        Text("The answer is:")
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.candidates)

                        Text("\(value)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Constants.Colors.primaryButton)
                            .frame(width: 40, height: 40)
                            .background(Constants.Colors.highlightHintAffected)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Spacer()
                    }
                }

                // Action buttons
                HStack(spacing: 16) {
                    Button(action: onDismiss) {
                        Text("Got it!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Constants.Colors.toolbarButton)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Constants.Colors.highlightRowColBox)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Button(action: onApply) {
                        Text("Place it for me")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Constants.Colors.primaryButton)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(20)
            .background(Constants.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -5)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()

        HintOverlayView(
            hint: TechniqueHint(
                technique: .nakedSingle,
                affectedCells: [40],
                eliminationCells: [],
                candidates: [5],
                explanation: "Cell R5C5 can only be 5 - all other numbers are already in the same row, column, or box."
            ),
            onApply: {},
            onDismiss: {}
        )
    }
}
