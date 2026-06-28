import SwiftUI

struct CreateRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel: CreateRequestViewModel
    @State private var isShowingAdditional = false
    @State private var isLoginPresented = false
    private let onCompleted: () -> Void

    init(
        service: SourcingRequestServiceProtocol,
        currentUser: AppUser? = nil,
        editingRequest: SourcingRequest? = nil,
        onCompleted: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: CreateRequestViewModel(service: service, currentUser: currentUser, editingRequest: editingRequest))
        self.onCompleted = onCompleted
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                header
                requestForm
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.medium)
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

                PrimaryButton(title: container.t(viewModel.isEditing ? "edit.submit" : "create.submit"), isLoading: viewModel.isSubmitting) {
                    guard container.currentUser != nil else {
                        isLoginPresented = true
                        return
                    }

                    Task { await viewModel.submit() }
                }
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.top, AppSpacing.small)
            .padding(.bottom, AppSpacing.small)
            .background(.ultraThinMaterial)
        }
        .background(AppColor.background)
        .navigationTitle(container.t(viewModel.isEditing ? "edit.title" : "create.title"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(container.t(viewModel.isEditing ? "edit.alert.title" : "create.alert.title"), isPresented: $viewModel.didSubmit) {
            Button(container.t("create.alert.ok")) {
                if viewModel.isEditing {
                    onCompleted()
                } else {
                    container.selectedTab = .home
                }
                dismiss()
            }
        } message: {
            Text(container.t(viewModel.isEditing ? "edit.alert.message" : "create.alert.message"))
        }
        .sheet(isPresented: $isLoginPresented) {
            NavigationStack {
                LoginView(onAuthenticated: submitAfterLogin)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                isLoginPresented = false
                            } label: {
                                Image(systemName: "xmark")
                            }
                            .accessibilityLabel(container.t("login.dismiss"))
                        }
                    }
            }
        }
    }

    private var requestForm: some View {
        AppListItem {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                tradeSection
                Hairline()
                productSection
                Hairline()
                contactSection
                Hairline()
                additionalSection
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(container.t(viewModel.isEditing ? "edit.top.title" : "create.top.title"))
                .font(.title2.weight(.bold))
                .foregroundStyle(AppColor.primaryText)

            Text(container.t("create.helper"))
                .font(.subheadline)
                .foregroundStyle(AppColor.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var tradeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            SectionHeader(title: container.t("create.trade.section"))

            HStack(spacing: 4) {
                tradeIntentButton(.buy)
                tradeIntentButton(.sell)
            }
            .padding(4)
            .background(AppColor.backgroundElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))

            VStack(alignment: .leading, spacing: AppSpacing.xsmall) {
                Text(container.t("create.trade.date"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColor.secondaryText)

                DatePicker("", selection: $viewModel.neededAt, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(AppColor.primaryAccent)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func tradeIntentButton(_ intent: TradeIntent) -> some View {
        let isSelected = viewModel.tradeIntent == intent
        return Button {
            viewModel.tradeIntent = intent
        } label: {
            Text(intent == .buy ? container.t("create.trade.buy") : container.t("create.trade.sell"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : AppColor.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(isSelected ? AppColor.primaryAccent : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var productSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            SectionHeader(title: container.t("create.product.section"))

            InputField(
                label: container.t("create.product.name"),
                placeholder: container.t("create.product.placeholder"),
                text: $viewModel.productName,
                error: localizedFieldError(.productName)
            )

            TextAreaField(
                label: container.t("create.product.description"),
                placeholder: container.t("create.product.description.placeholder"),
                text: $viewModel.productDescription
            )

            categoryPicker

            InputField(
                label: container.t("create.quantity"),
                placeholder: container.t("create.quantity.placeholder"),
                text: $viewModel.quantity
            )

            quantityUnitPicker

            InputField(
                label: container.t("create.market"),
                placeholder: container.t("create.market.placeholder"),
                text: $viewModel.targetMarket
            )
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xsmall) {
            Text(container.t("create.category"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.secondaryText)

            Menu {
                ForEach(viewModel.categories, id: \.self) { category in
                    Button {
                            viewModel.category = category
                            viewModel.fieldErrorKeys[.category] = nil
                    } label: {
                        if viewModel.category == category {
                            Label(container.localizedCategory(category), systemImage: "checkmark")
                        } else {
                            Text(container.localizedCategory(category))
                        }
                    }
                }
            } label: {
                HStack {
                    Text(container.localizedCategory(viewModel.category))
                        .font(.subheadline)
                        .foregroundStyle(AppColor.primaryText)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColor.secondaryText)
                }
                .padding(.horizontal, AppSpacing.medium)
                .frame(minHeight: 44)
                .background(AppColor.backgroundElevated)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
                        .stroke(localizedFieldError(.category) == nil ? AppColor.border : AppColor.error, lineWidth: 1)
                }
            }

            if let error = localizedFieldError(.category) {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(AppColor.error)
            }
        }
    }

    private var quantityUnitPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xsmall) {
            Text(container.t("create.quantity.unit"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.secondaryText)

            Menu {
                ForEach(viewModel.quantityUnits, id: \.self) { unit in
                    Button {
                        viewModel.quantityUnit = unit
                    } label: {
                        if viewModel.quantityUnit == unit {
                            Label(container.t("quantity.unit.\(unit)"), systemImage: "checkmark")
                        } else {
                            Text(container.t("quantity.unit.\(unit)"))
                        }
                    }
                }
            } label: {
                HStack {
                    Text(container.t("quantity.unit.\(viewModel.quantityUnit)"))
                        .font(.subheadline)
                        .foregroundStyle(AppColor.primaryText)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColor.secondaryText)
                }
                .padding(.horizontal, AppSpacing.medium)
                .frame(minHeight: 44)
                .background(AppColor.backgroundElevated)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                }
            }
        }
    }

    private var additionalSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowingAdditional.toggle()
                }
            } label: {
                HStack {
                    Text(container.t("create.additional.section"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.primaryText)
                    Spacer()
                    Image(systemName: isShowingAdditional ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColor.secondaryText)
                }
            }
            .buttonStyle(.plain)

            if isShowingAdditional {
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
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
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

    private func localizedFieldError(_ field: CreateRequestViewModel.Field) -> String? {
        guard let key = viewModel.fieldErrorKeys[field] else {
            return nil
        }

        return container.t(key)
    }

    private func submitAfterLogin() {
        guard let user = container.currentUser else { return }
        isLoginPresented = false
        viewModel.prefillContact(from: user)
        Task { await viewModel.submit() }
    }
}
