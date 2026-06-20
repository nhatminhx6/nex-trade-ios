import SwiftUI

struct AppSplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColor.heroGradientStart, AppColor.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(AppColor.softAccentBackground)
                        .frame(width: 88, height: 88)

                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 35, weight: .semibold))
                        .foregroundStyle(AppColor.primaryAccent)
                }
                .shadow(color: AppColor.primaryAccent.opacity(0.16), radius: 24, x: 0, y: 12)

                VStack(spacing: 5) {
                    Text("NexTrade")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(AppColor.primaryText)

                    Text("Modern Trade OS")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.secondaryText)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("NexTrade")
    }
}
