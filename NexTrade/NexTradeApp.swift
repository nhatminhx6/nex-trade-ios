import SwiftUI

@main
struct NexTradeApp: App {
    @StateObject private var container = AppContainer()
    @State private var isShowingSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppRootView()

                if isShowingSplash {
                    AppSplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .environmentObject(container)
            .task {
                try? await Task.sleep(nanoseconds: 1_150_000_000)
                withAnimation(.easeOut(duration: 0.25)) {
                    isShowingSplash = false
                }
            }
        }
    }
}
