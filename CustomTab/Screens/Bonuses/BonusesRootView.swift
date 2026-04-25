//
//  BonusesRootView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct BonusesRootView: View {
    @Environment(TabRouter.self) private var router

    private let screenBackground = Color(red: 0.18, green: 0.10, blue: 0.06)

    var body: some View {
        VStack(spacing: 16) {
            Text("Bonuses")
                .font(.title2)
                .bold()

            Button("Bonuses details") {
                router.push(.bonusesDetails, animated: true)
            }

            Button("Go to main") {
                router.selectTab(.main, setStack: [.mainRoot], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}
