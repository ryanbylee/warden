//
//  ShimmerModifier.swift
//  Warden
//

import SwiftUI

struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    if reduceMotion {
                        Color.primary.opacity(0.08)
                    } else {
                        shimmerGradient
                            .onAppear {
                                phase = -1
                                withAnimation(
                                    .linear(duration: 1.2)
                                    .repeatForever(autoreverses: false)
                                ) {
                                    phase = 1
                                }
                            }
                    }
                }
            }
    }

    private var shimmerGradient: some View {
        GeometryReader { geo in
            let width = geo.size.width
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white.opacity(0.35), location: 0.4),
                    .init(color: .clear, location: 1),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: width * 2)
            .offset(x: width * phase)
        }
        .clipped()
    }
}

extension View {
    func shimmer(when isActive: Bool) -> some View {
        modifier(ShimmerModifier(isActive: isActive))
    }
}
