//
//  AnimatedBorderView.swift
//  CustomTab
//
//  Created by Yaroslav Golinskiy on 16/04/2026.
//

import SwiftUI

struct AnimatedBorderView<Content: View>: View {
    private let cornerRadius: CGFloat
    private let backgroundColor: Color
    private let borderColor: Color
    private let borderWidth: CGFloat

    private let animatedBorderColor: Color
    private let animatedBorderWidth: CGFloat
    private let glowRadius: CGFloat
    private let duration: Double

    @ViewBuilder private let content: Content

    @State private var phase: CGFloat = 0

    init(
        cornerRadius: CGFloat = 16,
        backgroundColor: Color,
        borderColor: Color = .white.opacity(0.18),
        borderWidth: CGFloat = 1,
        animatedBorderColor: Color = .yellow,
        animatedBorderWidth: CGFloat = 2,
        glowRadius: CGFloat = 6,
        duration: Double = 1.2,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.animatedBorderColor = animatedBorderColor
        self.animatedBorderWidth = animatedBorderWidth
        self.glowRadius = glowRadius
        self.duration = duration
        self.content = content()
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            shape.fill(backgroundColor)

            shape.stroke(borderColor, lineWidth: borderWidth)

            shape
                .stroke(
                    AngularGradient(
                        colors: [
                            animatedBorderColor.opacity(0.0),
                            animatedBorderColor.opacity(0.0),
                            animatedBorderColor.opacity(0.95),
                            animatedBorderColor.opacity(0.0),
                            animatedBorderColor.opacity(0.0)
                        ],
                        center: .center,
                        angle: .degrees(phase)
                    ),
                    style: StrokeStyle(lineWidth: animatedBorderWidth, lineCap: .round)
                )
                .blur(radius: glowRadius)
                .blendMode(.screen)

            content
                .padding(14)
        }
        .onAppear {
            phase = 0
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                phase = 360
            }
        }
    }
}
