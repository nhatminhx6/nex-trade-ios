import SwiftUI

struct InputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var error: String?
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization? = .sentences
    var autocorrectionDisabled = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xsmall) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.secondaryText)

            TextField(placeholder, text: $text)
                .font(.subheadline)
                .foregroundStyle(AppColor.primaryText)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(autocorrectionDisabled)
                .padding(.horizontal, AppSpacing.medium)
                .frame(minHeight: 44)
                .background(AppColor.backgroundElevated)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
                        .stroke(error == nil ? AppColor.border : AppColor.error, lineWidth: 1)
                }

            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(AppColor.error)
            }
        }
    }
}
