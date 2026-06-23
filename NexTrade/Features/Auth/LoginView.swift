import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessageKey: String?
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                Spacer(minLength: 58)
                brand
                credentialsCard
                Spacer(minLength: 36)
            }
            .padding(.horizontal, AppSpacing.large)
        }
        .background(AppColor.background)
    }

    private var brand: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NEXTRADE")
                .font(.caption.weight(.bold))
                .tracking(2)
                .foregroundStyle(AppColor.primaryAccent)

            Text(container.t("login.title"))
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(AppColor.primaryText)

            Text(container.t("login.subtitle"))
                .font(.subheadline)
                .foregroundStyle(AppColor.secondaryText)
                .lineSpacing(4)
        }
    }

    private var credentialsCard: some View {
        AppCard(padding: 20, radius: AppRadius.xlarge) {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                InputField(
                    label: container.t("login.email"),
                    placeholder: "name@company.com",
                    text: $email,
                    keyboardType: .emailAddress,
                    textContentType: .username,
                    autocapitalization: .never,
                    autocorrectionDisabled: true
                )

                SecureInputField(
                    label: container.t("login.password"),
                    placeholder: container.t("login.password.placeholder"),
                    text: $password
                )

                if let errorMessageKey {
                    Text(container.t(errorMessageKey))
                        .font(.caption)
                        .foregroundStyle(AppColor.error)
                }

                PrimaryButton(title: container.t("login.submit"), isLoading: isLoading) {
                    Task { await login() }
                }
            }
        }
    }

    private func login() async {
        errorMessageKey = nil
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            errorMessageKey = "login.error.required"
            return
        }

        isLoading = true
        defer { isLoading = false }
        do {
            try await container.login(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
        } catch {
            errorMessageKey = "login.error.failed"
        }
    }
}

private struct SecureInputField: View {
    @EnvironmentObject private var container: AppContainer
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xsmall) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.primaryText)

            SecureField(placeholder, text: $text)
                .font(.body)
                .foregroundStyle(AppColor.primaryText)
                .textContentType(.password)
                .padding(.horizontal, AppSpacing.medium)
                .frame(minHeight: 48)
                .background(AppColor.backgroundElevated)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                }
        }
    }
}
