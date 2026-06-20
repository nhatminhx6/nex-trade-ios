import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }

                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [AppColor.primaryAccent, AppColor.accentDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: AppColor.primaryAccent.opacity(0.36), radius: 20, x: 0, y: 10)
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.75 : 1)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(AppColor.accentDark)
                .background(AppColor.softAccentBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .stroke(AppColor.primaryAccent.opacity(0.2), lineWidth: 1)
                }
        }
    }
}
