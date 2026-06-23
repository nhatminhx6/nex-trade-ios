import SwiftUI

struct TextAreaField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xsmall) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.secondaryText)

            TextField(placeholder, text: $text, axis: .vertical)
                .font(.subheadline)
                .foregroundStyle(AppColor.primaryText)
                .lineLimit(3...5)
                .padding(AppSpacing.medium)
                .frame(minHeight: 88, alignment: .topLeading)
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
