import SwiftUI

struct ThemeToggleButton: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        Button {
            container.toggleDarkMode()
        } label: {
            Image(systemName: container.isDarkMode ? "sun.max.fill" : "moon.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.primaryText)
                .frame(width: 32, height: 32)
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(container.isDarkMode ? "Chuyển sang giao diện sáng" : "Chuyển sang giao diện tối")
    }
}

struct ThemeToolbarItem: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ThemeToggleButton()
        }

        ToolbarItem(placement: .topBarTrailing) {
            LanguageToggleButton()
        }
    }
}

struct AppQuickControls: View {
    var body: some View {
        HStack(spacing: 8) {
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
                .frame(width: 32, height: 32)
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(container.language == .vietnamese ? "Switch to English" : "Đổi sang tiếng Việt")
    }
}
