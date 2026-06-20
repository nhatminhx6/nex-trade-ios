# NexTrade Project Context

## Tên dự án

NexTrade

## Tầm nhìn

NexTrade là app mobile-first để hỗ trợ tìm nguồn hàng trong lĩnh vực nông sản, thực phẩm, và xuất nhập khẩu.

## Roadmap dài hạn

### Phase 1

App SwiftUI để nhận yêu cầu sourcing, tạo niềm tin, thu lead, và bán các gói dịch vụ sourcing giá thấp.

### Phase 2

Dùng dữ liệu sourcing và mạng lưới nhà cung cấp để tìm cơ hội mở shop, brand, hoặc sản phẩm riêng.

### Phase 3

Xa hơn là xây dựng công ty xuất nhập khẩu trái cây.

## Định vị sản phẩm

NexTrade không phải marketplace trống. NexTrade là nền tảng sourcing có dịch vụ thật phía sau. User gửi yêu cầu tìm hàng; NexTrade hỗ trợ tìm, so sánh, và xác minh các lựa chọn nhà cung cấp.

## User mục tiêu

- Người làm xuất nhập khẩu nhỏ.
- Buyer ngành thực phẩm/nông sản.
- Chủ shop hoặc doanh nghiệp nhỏ.
- Người cần tìm nguồn hàng nhưng chưa biết bắt đầu từ đâu.

## Chiến lược tạo niềm tin

- Sourcing có người thật hỗ trợ.
- Sàng lọc nhà cung cấp.
- So sánh giá và MOQ.
- Kiểm tra đóng gói/chứng nhận.
- Quy trình rõ ràng.
- Gói dịch vụ minh bạch.
- UI chuyên nghiệp.

## Flow app chính

1. Home.
2. Request Sourcing.
3. Product Opportunities.
4. Sourcing Packages.
5. Request Status/Contact.

MVP hiện tập trung vào Home, Request Sourcing, Request Status và Profile/Contact. Product Opportunities và Sourcing Packages là hướng phát triển tiếp theo, chưa được triển khai.

## Định hướng thiết kế

Chuyên nghiệp, hiện đại, cao cấp vừa đủ, đáng tin, sạch và business-grade. Cảm giác nên gần fintech/logistics/B2B SaaS hơn marketplace tiêu dùng.

Theme hiện tại có tên `Modern Trade OS`: surface sáng, accent tím có độ tương phản tốt, dark mode riêng, card clean/glass nhẹ và typography gọn. UI phải luôn hỗ trợ tiếng Việt và tiếng Anh.

## Định hướng kỹ thuật

- iOS-first, SwiftUI, deployment target iOS 17+.
- Kiến trúc đơn giản, không overengineering.
- Chưa cần backend nếu chưa cần cho MVP validation.
- Data layer hiện dùng `SourcingRequestServiceProtocol` và `MockSourcingRequestService` in-memory để bảo toàn luồng UI/MVVM.
- `AppContainer` là nơi giữ service dùng chung, theme, language và tab selection.
- Không có third-party dependency. Project được sinh bằng XcodeGen từ `project.yml`.
