import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var container: AppContainer
    var onAuthenticated: (() -> Void)?
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
            onAuthenticated?()
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
    @State private var isPasswordVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xsmall) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.primaryText)

            ZStack(alignment: .trailing) {
                Group {
                    if isPasswordVisible {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .font(.body)
                .foregroundStyle(AppColor.primaryText)
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding(.leading, AppSpacing.medium)
                .padding(.trailing, 46)
                .frame(minHeight: 48)

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.secondaryText)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(container.t(isPasswordVisible ? "login.password.hide" : "login.password.show"))
            }
            .background(AppColor.backgroundElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 1)
            }
        }
    }
}
