//
//  RouteViewFactory.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

enum RouteViewFactory {
    
    @ViewBuilder
    static func makeView(for screen: ScreenRoute) -> some View {
        switch screen.id {
        case "main.root":
            MainRootView()
        case "main.details":
            MainDetailsView()

        case "lobby.root":
            LobbyRootView()
        case "lobby.details":
            LobbyDetailsView()

        case "menu.root":
            MenuRootView()

        case "bonuses.root":
            BonusesRootView()
        case "bonuses.details":
            BonusesDetailsView()

        case "profile.root":
            ProfileRootView()
        case "profile.details":
            ProfileDetailsView()

        default:
            VStack(spacing: 12) {
                Text("Невідомий екран")
                    .font(.title3).bold()
                Text(screen.id)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding()
            .tabScreenChrome(background: Color.black)
        }
    }
}
