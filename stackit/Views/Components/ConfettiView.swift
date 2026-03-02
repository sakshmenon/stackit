//
//  ConfettiView.swift
//  Dispatch
//
//  Full-screen particle confetti overlay shown when all demo tasks are complete.
//

import SwiftUI

// MARK: - Confetti View

/// Rains 140 coloured pieces from the top of the screen.
/// Pieces spin as they fall and fade out. Hit-testing is disabled so UI below stays interactive.
struct ConfettiView: View {
    @State private var animate = false
    @State private var pieces: [ConfettiPiece] = []

    var body: some View {
        GeometryReader { geo in
            ForEach(pieces) { piece in
                RoundedRectangle(cornerRadius: 2)
                    .fill(piece.color)
                    .frame(width: piece.width, height: piece.height)
                    .rotationEffect(.degrees(animate ? piece.endRotation : piece.startRotation))
                    .offset(
                        x: piece.xFraction * geo.size.width - piece.width / 2,
                        y: animate ? geo.size.height + 60 : -(piece.height + 20)
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeIn(duration: piece.duration).delay(piece.delay),
                        value: animate
                    )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            pieces = ConfettiPiece.generate(count: 140)
            // Small delay so the layout pass completes before animating
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { animate = true }
        }
    }
}

// MARK: - Particle model

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let xFraction: CGFloat      // 0…1 across screen width
    let width: CGFloat
    let height: CGFloat
    let startRotation: Double
    let endRotation: Double
    let delay: Double            // stagger so pieces don't all fall simultaneously
    let duration: Double         // fall duration in seconds

    private static let palette: [Color] = [
        .accentColor,
        Color(red: 0.20, green: 0.72, blue: 0.39),
        .orange,
        .pink,
        .yellow,
        .blue,
        .purple,
        .cyan,
        Color(red: 0.95, green: 0.33, blue: 0.33),
    ]

    static func generate(count: Int) -> [ConfettiPiece] {
        (0..<count).map { _ in
            let w = CGFloat.random(in: 6...12)
            return ConfettiPiece(
                color:         palette.randomElement()!,
                xFraction:     CGFloat.random(in: 0...1),
                width:         w,
                height:        w * CGFloat.random(in: 1.2...1.8),
                startRotation: Double.random(in: 0...180),
                endRotation:   Double.random(in: 540...900),
                delay:         Double.random(in: 0...2.2),
                duration:      Double.random(in: 1.6...3.2)
            )
        }
    }
}

#Preview {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        ConfettiView()
    }
}
