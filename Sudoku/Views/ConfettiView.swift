import SwiftUI

/// A confetti particle
struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let rotation: Double
    let scale: CGFloat
    let shape: ConfettiShape

    enum ConfettiShape {
        case circle, square, triangle, star
    }
}

/// Confetti celebration animation
struct ConfettiView: View {
    @State private var pieces: [ConfettiPiece] = []
    @State private var animate = false

    let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        Constants.Colors.easyColor,
        Constants.Colors.mediumColor,
        Constants.Colors.hardColor
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(pieces) { piece in
                    ConfettiPieceView(piece: piece)
                        .position(x: piece.x, y: piece.y)
                }
            }
            .onAppear {
                createConfetti(in: geometry.size)
                withAnimation(.easeOut(duration: 3.0)) {
                    animate = true
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func createConfetti(in size: CGSize) {
        pieces = (0..<80).map { _ in
            let startX = CGFloat.random(in: 0...size.width)
            let shape = [ConfettiPiece.ConfettiShape.circle, .square, .triangle, .star].randomElement()!

            return ConfettiPiece(
                x: startX,
                y: -20,
                color: colors.randomElement()!,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.2),
                shape: shape
            )
        }

        // Animate each piece falling
        for i in pieces.indices {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 2.0...3.5)
            let endX = pieces[i].x + CGFloat.random(in: -100...100)
            let endY = size.height + 50

            withAnimation(.easeIn(duration: duration).delay(delay)) {
                pieces[i].x = endX
                pieces[i].y = endY
            }
        }
    }
}

/// Individual confetti piece view
struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    @State private var rotation: Double = 0

    var body: some View {
        Group {
            switch piece.shape {
            case .circle:
                Circle()
                    .fill(piece.color)
                    .frame(width: 10 * piece.scale, height: 10 * piece.scale)
            case .square:
                Rectangle()
                    .fill(piece.color)
                    .frame(width: 10 * piece.scale, height: 10 * piece.scale)
            case .triangle:
                Triangle()
                    .fill(piece.color)
                    .frame(width: 12 * piece.scale, height: 12 * piece.scale)
            case .star:
                Star()
                    .fill(piece.color)
                    .frame(width: 12 * piece.scale, height: 12 * piece.scale)
            }
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.linear(duration: Double.random(in: 1...3)).repeatForever(autoreverses: false)) {
                rotation = piece.rotation + 360
            }
        }
    }
}

/// Triangle shape for confetti
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Star shape for confetti
struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        var path = Path()

        for i in 0..<10 {
            let angle = (Double(i) * 36 - 90) * .pi / 180
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
        ConfettiView()
    }
}
