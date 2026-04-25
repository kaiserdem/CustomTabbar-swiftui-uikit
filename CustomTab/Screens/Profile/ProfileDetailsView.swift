//
//  ProfileDetailsView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct ProfileDetailsView: View {
    @Environment(TabRouter.self) private var router

    private let screenBackground = Color(red: 0.08, green: 0.07, blue: 0.26)

    var body: some View {
        VStack(spacing: 16) {
            Text("Profile details")
                .font(.title2)
                .bold()

            Button("Open menu") {
                router.selectTab(.menu, setStack: [.menuRoot], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}
