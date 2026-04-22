//
//  BonusesDetailsView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct BonusesDetailsView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.22, green: 0.12, blue: 0.07)

    var body: some View {
        VStack(spacing: 16) {
            Text("Деталі бонусів")
                .font(.title2)
                .bold()

            Button("Відкрити лоббі") {
                router.selectTab(.lobby, setStack: [.lobbyRoot], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}
