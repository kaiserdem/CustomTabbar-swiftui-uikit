//
//  ShimmerButton.swift
//  CustomTab
//
//  Created by Yaroslav Golinskiy on 16/04/2026.
//

import SwiftUI

struct ShimmerButton: View {
    let title: String
    let width: CGFloat?
    let height: CGFloat

    let borderColor: Color
    let backgroundColor: AnyShapeStyle
    let textColor: Color
    let fontSize: CGFloat

    let action: () -> Void

    @State private var offset: CGFloat = -200

    init(
        title: String,
        width: CGFloat? = nil,
        height: CGFloat = 60,
        borderColor: Color = .yellow,
        backgroundColor: Color = Color.black.opacity(0.7),
        textColor: Color = .yellow,
        fontSize: CGFloat = 20,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.width = width
        self.height = height
        self.borderColor = borderColor
        self.backgroundColor = AnyShapeStyle(backgroundColor)
        self.textColor = textColor
        self.fontSize = fontSize
        self.action = action
    }

    init(
        title: String,
        width: CGFloat? = nil,
        height: CGFloat = 60,
        borderColor: Color = .yellow,
        backgroundColor: LinearGradient,
        textColor: Color = .yellow,
        fontSize: CGFloat = 20,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.width = width
        self.height = height
        self.borderColor = borderColor
        self.backgroundColor = AnyShapeStyle(backgroundColor)
        self.textColor = textColor
        self.fontSize = fontSize
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                let radius = height / 2

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

                Text(title)
                    .font(.system(size: fontSize, weight: .black, design: .rounded))
                    .foregroundStyle(textColor)
                    .shadow(color: textColor.opacity(0.6), radius: 6)
            }
            .frame(width: width, height: height)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            let buttonWidth = width ?? geometry.size.width
                            let shimmerWidth: CGFloat = buttonWidth > 0 ? buttonWidth + 200 : 400
                            animate(to: shimmerWidth)
                        }
                        .onChange(of: geometry.size.width) { _, newWidth in
                            guard width == nil else { return }
                            let shimmerWidth: CGFloat = newWidth > 0 ? newWidth + 200 : 400
                            animate(to: shimmerWidth)
                        }
                }
            )
        }
        .buttonStyle(.plain)
    }

    private func animate(to shimmerWidth: CGFloat) {
        offset = -200
        withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
            offset = shimmerWidth
        }
    }
}
