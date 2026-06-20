import SwiftUI

struct CreateRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel: CreateRequestViewModel

    init(service: SourcingRequestServiceProtocol) {
        _viewModel = StateObject(wrappedValue: CreateRequestViewModel(service: service))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                header
                productSection
                additionalSection
                contactSection
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.large)
            .padding(.bottom, 92)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: AppSpacing.small) {
                if let errorMessageKey = viewModel.errorMessageKey {
                    Text(container.t(errorMessageKey))
                        .font(.caption)
                        .foregroundStyle(AppColor.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                PrimaryButton(title: container.t("create.submit"), isLoading: viewModel.isSubmitting) {
                    Task {
                        await viewModel.submit()
                    }
                }
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.top, AppSpacing.medium)
            .padding(.bottom, AppSpacing.small)
            .background(.ultraThinMaterial)
        }
        .background(AppColor.background)
        .navigationTitle(container.t("create.title"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(container.t("create.alert.title"), isPresented: $viewModel.didSubmit) {
            Button(container.t("create.alert.ok")) {
                container.selectedTab = .home
                dismiss()
            }
        } message: {
            Text(container.t("create.alert.message"))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            AppTopBar(eyebrow: "REQUEST INTAKE", title: container.t("create.top.title"))

            HStack(alignment: .top, spacing: AppSpacing.medium) {
                Text("01")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(AppColor.primaryAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(container.t("create.helper"))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppColor.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .stroke(AppColor.glassStroke.opacity(0.85), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.11), radius: 18, x: 0, y: 10)
        }
    }

    private var productSection: some View {
        AppCard(padding: 18, radius: AppRadius.large) {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionHeader(title: container.t("create.product.section"))

                InputField(
                    label: container.t("create.product.name"),
                    placeholder: container.t("create.product.placeholder"),
                    text: $viewModel.productName,
                    error: localizedFieldError(.productName)
                )

                categoryPicker

                InputField(
                    label: container.t("create.quantity"),
                    placeholder: container.t("create.quantity.placeholder"),
                    text: $viewModel.quantity
                )

                InputField(
                    label: container.t("create.market"),
                    placeholder: container.t("create.market.placeholder"),
                    text: $viewModel.targetMarket
                )
            }
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xsmall) {
            Text(container.t("create.category"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.small) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        CategoryPill(title: container.localizedCategory(category), isSelected: viewModel.category == category) {
                            viewModel.category = category
                            viewModel.fieldErrorKeys[.category] = nil
                        }
                    }
                }
                .padding(.vertical, 1)
            }

            if let error = localizedFieldError(.category) {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(AppColor.error)
            }
        }
    }

    private var additionalSection: some View {
        AppCard(padding: 18, radius: AppRadius.large) {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionHeader(title: container.t("create.additional.section"))

                InputField(
                    label: container.t("create.budget"),
                    placeholder: container.t("create.budget.placeholder"),
                    text: $viewModel.budget
                )

                TextAreaField(
                    label: container.t("create.note"),
                    placeholder: container.t("create.note.placeholder"),
                    text: $viewModel.note
                )
            }
        }
    }

    private var contactSection: some View {
        AppCard(padding: 18, radius: AppRadius.large) {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionHeader(title: container.t("create.contact.section"), subtitle: container.t("create.contact.subtitle"))

                InputField(
                    label: container.t("create.contact.name"),
                    placeholder: container.t("create.contact.name"),
                    text: $viewModel.contactName,
                    textContentType: .name
                )

                InputField(
                    label: container.t("create.phone"),
                    placeholder: container.t("create.phone"),
                    text: $viewModel.contactPhone,
                    error: localizedFieldError(.contactPhone),
                    keyboardType: .phonePad,
                    textContentType: .telephoneNumber,
                    autocapitalization: .never,
                    autocorrectionDisabled: true
                )

                InputField(
                    label: container.t("create.email"),
                    placeholder: container.t("create.email"),
                    text: $viewModel.contactEmail,
                    error: localizedFieldError(.contactEmail),
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress,
                    autocapitalization: .never,
                    autocorrectionDisabled: true
                )
            }
        }
    }

    private func localizedFieldError(_ field: CreateRequestViewModel.Field) -> String? {
        guard let key = viewModel.fieldErrorKeys[field] else {
            return nil
        }

        return container.t(key)
    }
}
