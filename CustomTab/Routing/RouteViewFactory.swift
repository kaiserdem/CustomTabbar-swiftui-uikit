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
        case "home.root":
            HomeRootView()
        case "home.details":
            HomeDetailsView()

        case "browse.root":
            BrowseRootView()
        case "browse.details":
            BrowseDetailsView()

        case "create.root":
            CreateRootView()

        case "notifications.root":
            NotificationsRootView()
        case "notifications.details":
            NotificationsDetailsView()

        case "profile.root":
            ProfileRootView()
        case "profile.settings":
            ProfileSettingsView()

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
