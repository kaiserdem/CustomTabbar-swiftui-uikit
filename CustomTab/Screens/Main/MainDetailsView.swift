//
//  MainDetailsView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct MainDetailsView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.09, green: 0.12, blue: 0.28)

    var body: some View {
        VStack(spacing: 16) {
            Text("Деталі")
                .font(.title2)
                .bold()

            Button("Лоббі: деталі в іншій вкладці") {
                router.selectTab(.lobby, setStack: [.lobbyRoot, .lobbyDetails], animated: true)
            }

            Button("Назад") {
                router.pop(animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}
