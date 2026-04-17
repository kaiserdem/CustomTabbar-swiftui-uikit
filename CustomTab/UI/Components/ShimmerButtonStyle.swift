//
//  ShimmerButtonStyle.swift
//  CustomTab
//
//  Created by Yaroslav Golinskiy on 16/04/2026.
//

import SwiftUI

struct ShimmerButtonStyle: ButtonStyle {
    let borderColor: Color
    let backgroundColor: AnyShapeStyle

    init(
        borderColor: Color = .yellow,
        backgroundColor: AnyShapeStyle = AnyShapeStyle(Color.black.opacity(0.7))
    ) {
        self.borderColor = borderColor
        self.backgroundColor = backgroundColor
    }

    init(
        borderColor: Color = .yellow,
        backgroundColor: LinearGradient
    ) {
        self.borderColor = borderColor
        self.backgroundColor = AnyShapeStyle(backgroundColor)
    }

    func makeBody(configuration: Configuration) -> some View {
        ShimmerButtonStyleBody(
            configuration: configuration,
            borderColor: borderColor,
            backgroundColor: backgroundColor
        )
    }
}

private struct ShimmerButtonStyleBody: View {
    let configuration: ButtonStyle.Configuration
    let borderColor: Color
    let backgroundColor: AnyShapeStyle

    @State private var offset: CGFloat = -200

    var body: some View {
        configuration.label
            .background(
                GeometryReader { geometry in
                    ZStack {
                        let radius = geometry.size.height / 2

                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(backgroundColor)

                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(borderColor.opacity(0.4), lineWidth: 2.5)

                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        borderColor.opacity(0.8),
                                        borderColor,
                                        borderColor.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 4
                            )

                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.yellow.opacity(0.6),
                                        Color.yellow,
                                        Color.orange.opacity(0.8),
                                        Color.yellow,
                                        Color.yellow.opacity(0.6)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 5
                            )
                            .blur(radius: 2)
                            .mask(
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.clear, .white, .clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 120)
                                    .offset(x: offset)
                            )
                    }
                    .onAppear {
                        animate(toWidth: geometry.size.width)
                    }
                    .onChange(of: geometry.size.width) { _, newWidth in
                        animate(toWidth: newWidth)
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }

    private func animate(toWidth width: CGFloat) {
        let shimmerWidth = width + 200
        offset = -200
        withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
            offset = shimmerWidth
        }
    }
}
