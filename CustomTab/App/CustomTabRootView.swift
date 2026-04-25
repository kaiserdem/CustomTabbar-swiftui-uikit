//
//  CustomTabRootView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct CustomTabRootView: View {
    @State private var router = TabRouter(initialTab: .main)

    var body: some View {
        TabControllerHost(router: router)
            .ignoresSafeArea(.all)
            .preferredColorScheme(.dark)
    }
}

private struct TabControllerHost: UIViewControllerRepresentable {
    let router: TabRouter

    func makeUIViewController(context: Context) -> CustomTabController {
        let controller = CustomTabController(router: router)
        return controller
    }

    func updateUIViewController(_ uiViewController: CustomTabController, context: Context) {
        
    }
}

