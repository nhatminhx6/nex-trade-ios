import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        TabView(selection: $container.selectedTab) {
            NavigationStack {
                HomeView()
                    .toolbar {
                        ThemeToolbarItem()
                    }
            }
            .tabItem {
                Label(container.t("tab.home"), systemImage: "house")
            }
            .tag(AppTab.home)

            NavigationStack {
                RequestsListView()
                    .toolbar {
                        ThemeToolbarItem()
                    }
            }
            .tabItem {
                Label(container.t("tab.requests"), systemImage: "list.bullet.rectangle")
            }
            .tag(AppTab.requests)

            NavigationStack {
                ProfileView()
                    .toolbar {
                        ThemeToolbarItem()
                    }
            }
            .tabItem {
                Label(container.t("tab.profile"), systemImage: "person")
            }
            .tag(AppTab.profile)
        }
        .tint(AppColor.primaryAccent)
        .preferredColorScheme(container.preferredColorScheme)
    }
}
