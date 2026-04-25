//
//  LobbyRootView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct LobbyRootView: View {
    @Environment(TabRouter.self) private var router

    private let screenBackground = Color(red: 0.06, green: 0.16, blue: 0.12)

    var body: some View {
        VStack(spacing: 16) {
            Text("Lobby")
                .font(.title2)
                .bold()

            Button("Lobby details") {
                router.push(.lobbyDetails, animated: true)
            }

            Button("Bonuses: show details") {
                router.selectTab(.bonuses, setStack: [.bonusesRoot, .bonusesDetails], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}
