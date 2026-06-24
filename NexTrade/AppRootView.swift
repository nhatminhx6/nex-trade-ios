import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        mainTabs.task {
            await container.restoreSession()
        }
    }

    private var mainTabs: some View {
        TabView(selection: $container.selectedTab) {
            NavigationStack {
                ApprovedListingsView(service: container.approvedListingService)
            }
            .tabItem {
                Label(container.t("tab.home"), systemImage: "house")
            }
            .tag(AppTab.home)

            NavigationStack {
                HomeView()
            }
            .tabItem { Label(container.t("tab.discover"), systemImage: "magnifyingglass") }
            .tag(AppTab.discover)

            NavigationStack {
                RequestsListView()
            }
            .tabItem {
                Label(container.t("tab.requests"), systemImage: "list.bullet.rectangle")
            }
            .tag(AppTab.requests)

            NavigationStack {
                ProfileView()
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
