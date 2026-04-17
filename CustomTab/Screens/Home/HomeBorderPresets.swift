//
//  HomeBorderPresets.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

enum HomeBorderPresets {
    struct Preset: Identifiable {
        let id: String
        let background: Color
        let border: Color
        let animatedBorder: Color
    }

    static let all: [Preset] = [
        .init(id: "Gold", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 1.00, green: 0.84, blue: 0.20)),
        .init(id: "Emerald", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 0.20, green: 0.95, blue: 0.62)),
        .init(id: "Ruby", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 1.00, green: 0.25, blue: 0.35)),
        .init(id: "Sapphire", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 0.30, green: 0.62, blue: 1.00)),
        .init(id: "Amethyst", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 0.72, green: 0.35, blue: 1.00)),
        .init(id: "Neon Pink", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 1.00, green: 0.24, blue: 0.78)),
        .init(id: "Cyan", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 0.20, green: 0.92, blue: 1.00)),
        .init(id: "Orange", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 1.00, green: 0.55, blue: 0.18)),
        .init(id: "Lime", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 0.74, green: 1.00, blue: 0.22)),
        .init(id: "Ice", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color.white.opacity(0.95))
    ]
}
