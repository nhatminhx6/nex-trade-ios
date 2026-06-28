import SwiftUI

struct RequestDetailView: View {
    @EnvironmentObject private var container: AppContainer
    @Environment(\.dismiss) private var dismiss
    @State private var request: SourcingRequest
    @State private var isEditing = false
    @State private var isDeleteConfirmationPresented = false
    @State private var isDeleting = false
    @State private var errorMessageKey: String?

    init(request: SourcingRequest) {
        _request = State(initialValue: request)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                if let errorMessageKey {
                    Text(container.t(errorMessageKey))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColor.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                header
                productSection
                contactSection
                noteSection
                deleteSection
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColor.background)
        .navigationTitle(container.t("detail.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isEditing = true
                } label: {
                    Text(container.t("detail.edit.short"))
                        .font(.subheadline.weight(.semibold))
                }
                .disabled(isDeleting)
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                CreateRequestView(
                    service: container.sourcingRequestService,
                    currentUser: container.currentUser,
                    editingRequest: request,
                    onCompleted: refreshRequest
                )
            }
        }
        .alert(container.t("detail.delete.confirm.title"), isPresented: $isDeleteConfirmationPresented) {
            Button(container.t("detail.delete.cancel"), role: .cancel) {}
            Button(container.t("detail.delete.confirm"), role: .destructive) {
                Task { await deleteRequest() }
            }
        } message: {
            Text(container.t("detail.delete.confirm.message"))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                HStack(alignment: .top) {
                    Text("CASE FILE")
                        .font(AppTypography.eyebrow)
                        .tracking(1.2)
                        .foregroundStyle(AppColor.primaryAccent)

                    Spacer()

                    StatusBadgeView(status: request.status)
                }

                Text(request.productName)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(AppColor.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(container.t("detail.created"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColor.secondaryText)

                    Text(request.createdAt.formatted(date: .long, time: .shortened))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.primaryText)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xlarge, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.xlarge, style: .continuous)
                .stroke(AppColor.glassStroke.opacity(0.86), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 14)
    }

    private var productSection: some View {
        DetailSection(title: container.t("detail.product.section")) {
            DetailRow(label: container.t("detail.category"), value: container.localizedCategory(request.category))
            DetailRow(label: container.t("detail.trade.intent"), value: tradeIntentTitle)
            DetailRow(label: container.t("detail.trade.time"), value: request.neededAt.formatted(date: .long, time: .omitted))
            DetailRow(label: container.t("detail.product.description"), value: request.productDescription)
            DetailRow(label: container.t("detail.quantity"), value: "\(request.quantity) \(container.t("quantity.unit.\(request.quantityUnit)"))")
            DetailRow(label: container.t("detail.market"), value: request.targetMarket)
            DetailRow(label: container.t("detail.budget"), value: request.budget)
            DetailRow(label: container.t("detail.note"), value: request.note)
            DetailRow(label: container.t("detail.status"), value: request.status.localizedDisplayTitle(language: container.language))
        }
    }

    private var tradeIntentTitle: String {
        request.tradeIntent == .buy ? container.t("create.trade.buy") : container.t("create.trade.sell")
    }

    private var contactSection: some View {
        DetailSection(title: container.t("detail.contact.section")) {
            DetailRow(label: container.t("detail.contact.name"), value: request.contactName)
            DetailRow(label: container.t("detail.phone"), value: request.contactPhone)
            DetailRow(label: container.t("detail.email"), value: request.contactEmail)
        }
    }

    private var noteSection: some View {
        DetailSection(title: container.t("detail.admin.note")) {
            DetailRow(label: container.t("detail.content"), value: request.adminNote ?? "")
        }
    }

    private var deleteSection: some View {
        Button(role: .destructive) {
            isDeleteConfirmationPresented = true
        } label: {
            HStack(spacing: 8) {
                if isDeleting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "trash")
                        .font(.subheadline.weight(.semibold))
                }

                Text(container.t("detail.delete"))
                    .font(.headline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(.white)
            .background(AppColor.error)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isDeleting)
        .opacity(isDeleting ? 0.75 : 1)
        .padding(.top, AppSpacing.small)
    }

    private func refreshRequest() {
        Task {
            guard let updatedRequest = try? await container.sourcingRequestService.fetchRequest(id: request.id) else { return }
            request = updatedRequest
        }
    }

    private func deleteRequest() async {
        isDeleting = true
        errorMessageKey = nil
        defer { isDeleting = false }

        do {
            try await container.sourcingRequestService.deleteRequest(id: request.id)
            dismiss()
        } catch let error as APIError {
            errorMessageKey = error.messageKey
        } catch {
            errorMessageKey = "error.delete"
        }
    }
}

private struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            SectionHeader(title: title)

            AppCard(padding: 0, radius: AppRadius.large) {
                VStack(spacing: 0) {
                    content
                }
            }
        }
    }
}

private struct DetailRow: View {
    @EnvironmentObject private var container: AppContainer
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xsmall) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.secondaryText)

            Text(value.isEmpty ? container.t("detail.not.provided") : value)
                .font(.body.weight(.medium))
                .foregroundStyle(AppColor.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.medium)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppColor.border)
                .frame(height: 1)
                .padding(.leading, AppSpacing.medium)
        }
    }
}
