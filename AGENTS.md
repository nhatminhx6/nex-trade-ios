# NexTrade Agent Guide

## Bắt đầu mỗi session

1. Đọc `PROJECT_CONTEXT.md` và `TASK_LOG.md` trước khi đọc hoặc sửa code.
2. Kiểm tra cấu trúc repo và trạng thái code hiện tại trước khi đề xuất thay đổi.
3. Luôn tiếp tục từ trạng thái app đang có; không làm lại từ đầu và không thay thế các phần đã hoàn thành nếu không có yêu cầu rõ ràng.

## Nguyên tắc triển khai

- NexTrade là dự án iOS native dùng SwiftUI, deployment target iOS 17+.
- Mọi thay đổi cần nhỏ, sạch, dễ kiểm soát, tương thích với luồng MVVM/data flow hiện có và có định hướng production.
- Không thêm dependency mới nếu chưa thật sự cần thiết cho MVP hoặc không thể giải quyết tốt bằng SwiftUI/Foundation có sẵn.
- Không refactor ngoài phạm vi task. Không xóa hoặc revert thay đổi có sẵn của người dùng/session trước.
- Sau khi sửa code, chạy build phù hợp. Với project hiện tại, dùng `xcodegen generate` trước khi build nếu có thêm/xóa Swift file, sau đó chạy:
  `xcodebuild -project NexTrade.xcodeproj -scheme NexTrade -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/NexTradeDerivedData build`

## Định hướng sản phẩm và UI

- Giữ UI theo B2B sourcing: hiện đại, chuyên nghiệp, cao cấp vừa đủ và đáng tin.
- NexTrade là nền tảng sourcing có dịch vụ thật phía sau, không phải app crypto/trading và không phải farming app.
- Tránh marketplace rẻ tiền, màu mè trẻ con, icon/emoji ngẫu nhiên, gradient không có mục đích và dữ liệu giả làm giảm uy tín.
- Ưu tiên các phần tạo niềm tin, form gửi yêu cầu tìm nguồn, thu lead, theo dõi tiến độ case và các gói dịch vụ sourcing giá thấp.
- Tôn trọng design system hiện có (`AppColor`, `AppSpacing`, `AppRadius`, shared components), light/dark mode và Việt/Anh runtime localization.

## Kết thúc mỗi task code

Cập nhật `TASK_LOG.md` với:

- Đã thay đổi gì.
- Các file đã đụng tới.
- Trạng thái app hiện tại.
- Các vấn đề hoặc gap còn tồn tại.
- Task tiếp theo nên làm.
