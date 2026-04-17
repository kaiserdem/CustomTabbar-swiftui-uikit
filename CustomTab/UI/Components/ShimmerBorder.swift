//
//  ShimmerBorder.swift
//  CustomTab
//
//  Created by Yaroslav Golinskiy on 16/04/2026.
//

import SwiftUI

struct ShimmerBorder: ViewModifier {
    let cornerRadius: CGFloat

    @State private var offset: CGFloat = -200

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.yellow.opacity(0.8),
                                        Color.orange.opacity(0.6)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 3
                            )

                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
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
                                lineWidth: 4
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
    }

    private func animate(toWidth width: CGFloat) {
        let shimmerWidth = width + 200
        offset = -200
        withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
            offset = shimmerWidth
        }
    }
}

extension View {
    func shimmerBorder(cornerRadius: CGFloat = 20) -> some View {
        modifier(ShimmerBorder(cornerRadius: cornerRadius))
    }
}
