import SwiftUI

enum SourcingRequestStatus: String, CaseIterable, Hashable {
    case new
    case reviewing
    case quoted
    case approved
    case rejected
    case completed
    case cancelled

    var displayTitle: String {
        localizedDisplayTitle(language: .vietnamese)
    }

    func localizedDisplayTitle(language: AppLanguage) -> String {
        switch self {
        case .new:
            AppText.values["status.new.title"]?[language] ?? "Yêu cầu mới"
        case .reviewing:
            AppText.values["status.reviewing.title"]?[language] ?? "Đang kiểm tra"
        case .quoted:
            AppText.values["status.quoted.title"]?[language] ?? "Đã phản hồi giá"
        case .approved:
            AppText.values["status.approved.title"]?[language] ?? "Đã duyệt"
        case .rejected:
            AppText.values["status.rejected.title"]?[language] ?? "Từ chối"
        case .completed:
            AppText.values["status.completed.title"]?[language] ?? "Hoàn tất"
        case .cancelled:
            AppText.values["status.cancelled.title"]?[language] ?? "Đã hủy"
        }
    }

    var badgeLabel: String {
        localizedBadgeLabel(language: .vietnamese)
    }

    func localizedBadgeLabel(language: AppLanguage) -> String {
        switch self {
        case .new:
            AppText.values["status.new.badge"]?[language] ?? "Mới"
        case .reviewing:
            AppText.values["status.reviewing.badge"]?[language] ?? "Đang xử lý"
        case .quoted:
            AppText.values["status.quoted.badge"]?[language] ?? "Có báo giá"
        case .approved:
            AppText.values["status.approved.badge"]?[language] ?? "Đã duyệt"
        case .rejected:
            AppText.values["status.rejected.badge"]?[language] ?? "Từ chối"
        case .completed:
            AppText.values["status.completed.badge"]?[language] ?? "Hoàn tất"
        case .cancelled:
            AppText.values["status.cancelled.badge"]?[language] ?? "Đã hủy"
        }
    }

    var badgeColor: Color {
        switch self {
        case .new:
            AppColor.primaryAccent
        case .reviewing:
            AppColor.processing
        case .quoted:
            AppColor.accentDark
        case .approved:
            AppColor.success
        case .rejected:
            AppColor.error
        case .completed:
            AppColor.success
        case .cancelled:
            AppColor.error
        }
    }
}
