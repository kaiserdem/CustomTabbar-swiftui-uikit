import SwiftUI

struct CustomTabRootView: View {
    @StateObject private var router = TabRouter(initialTab: .home)

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

