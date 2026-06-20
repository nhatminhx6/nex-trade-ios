import SwiftUI

struct ThemeToggleButton: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        Button {
            container.toggleDarkMode()
        } label: {
            Image(systemName: container.isDarkMode ? "sun.max.fill" : "moon.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppColor.primaryAccent)
                .frame(width: 34, height: 34)
                .background(AppColor.surface)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(AppColor.glassStroke.opacity(0.75), lineWidth: 1)
                }
                .shadow(color: AppColor.primaryAccent.opacity(0.24), radius: 14, x: 0, y: 7)
        }
        .accessibilityLabel(container.isDarkMode ? "Chuyển sang giao diện sáng" : "Chuyển sang giao diện tối")
    }
}

struct ThemeToolbarItem: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            LanguageToggleButton()
            ThemeToggleButton()
        }
    }
}

struct LanguageToggleButton: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        Button {
            container.toggleLanguage()
        } label: {
            Text(container.language.rawValue)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColor.primaryAccent)
                .frame(width: 36, height: 34)
                .background(AppColor.surface)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(AppColor.glassStroke.opacity(0.75), lineWidth: 1)
                }
                .shadow(color: AppColor.primaryAccent.opacity(0.16), radius: 12, x: 0, y: 6)
        }
        .accessibilityLabel(container.language == .vietnamese ? "Switch to English" : "Đổi sang tiếng Việt")
    }
}
