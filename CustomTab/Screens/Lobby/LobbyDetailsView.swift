//
//  LobbyDetailsView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct LobbyDetailsView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.05, green: 0.20, blue: 0.14)

    var body: some View {
        VStack(spacing: 16) {
            Text("Деталі лоббі")
                .font(.title2)
                .bold()

            Button("Головна: показати деталі") {
                router.selectTab(.main, setStack: [.mainRoot, .mainDetails], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}
