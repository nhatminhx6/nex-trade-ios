import SwiftUI

struct TextAreaField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xsmall) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.primaryText)

            TextField(placeholder, text: $text, axis: .vertical)
                .font(.body)
                .foregroundStyle(AppColor.primaryText)
                .lineLimit(4...7)
                .padding(AppSpacing.medium)
                .frame(minHeight: 112, alignment: .topLeading)
                .background(AppColor.backgroundElevated)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
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
