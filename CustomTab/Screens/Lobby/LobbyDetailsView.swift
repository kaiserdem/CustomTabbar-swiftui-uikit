//
//  LobbyDetailsView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct LobbyDetailsView: View {
    @Environment(TabRouter.self) private var router

    private let screenBackground = Color(red: 0.05, green: 0.20, blue: 0.14)

    var body: some View {
        VStack(spacing: 16) {
            Text("Lobby details")
                .font(.title2)
                .bold()

            Button("Main: show details") {
                router.selectTab(.main, setStack: [.mainRoot, .mainDetails], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}
