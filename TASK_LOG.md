# NexTrade Task Log

## Trạng thái hiện tại

NexTrade là SwiftUI MVP iOS 17+ với luồng sourcing end-to-end ở mức local/in-memory. App có splash, TabView gồm Home/Requests/Profile, tạo sourcing request, success alert, dashboard request gần đây, request queue có search/filter, và request detail.

Theme `Modern Trade OS` đã có design system tập trung, runtime dark mode và runtime localization Việt/Anh. App sử dụng `MockSourcingRequestService`, vì vậy dữ liệu request chỉ tồn tại trong phiên chạy app và chưa có backend/persistence.

Build gần nhất trước khi tạo bộ nhớ dự án đã chạy thành công bằng XcodeGen và `xcodebuild` với derived data ở `/tmp/NexTradeDerivedData`.

## Những phần đã hoàn thành

- XcodeGen project `NexTrade.xcodeproj`, iOS 17+, SwiftUI native.
- `AppContainer` chia sẻ sourcing service, app theme, ngôn ngữ và tab selection.
- Splash NexTrade khi launch.
- Tab navigation: Home, Requests, Profile.
- Modern Trade OS design system: dynamic colors cho light/dark mode, spacing, radius, typography và shared UI components.
- Việt/Anh runtime localization qua `AppLocalization.swift` và language toggle.
- Home command center: hero CTA, request snapshot, recent requests, workflow, category discovery và value cards.
- Create Request custom `ScrollView` form: product, category, quantity, market, budget, note, contact; validation inline; success alert.
- Success action quay về Home để request mới hiển thị ở dashboard.
- Requests queue: custom request cards, pull-to-refresh, search theo product/market, filter trạng thái kèm count, trạng thái empty/loading.
- Request detail: case header, product/contact sections, status, NexTrade note và created date.
- Profile: service summary, contact information placeholder và services hiện tại.

## File quan trọng

- `project.yml`: cấu hình XcodeGen và iOS 17 target.
- `NexTrade/NexTradeApp.swift`: app entry, splash lifecycle.
- `NexTrade/AppRootView.swift`: main TabView và navigation roots.
- `NexTrade/Core/AppContainer.swift`: shared app state.
- `NexTrade/Core/SourcingRequest.swift`: request model.
- `NexTrade/Core/SourcingRequestServiceProtocol.swift`: data contract.
- `NexTrade/Core/MockSourcingRequestService.swift`: in-memory implementation hiện tại.
- `NexTrade/Features/Home/HomeView.swift`: dashboard Home.
- `NexTrade/Features/Home/HomeDashboardViewModel.swift`: Home request summary/recent list state.
- `NexTrade/Features/CreateRequest/CreateRequestView.swift`: custom sourcing request form.
- `NexTrade/Features/CreateRequest/CreateRequestViewModel.swift`: validation và submit flow.
- `NexTrade/Features/Requests/RequestsListView.swift`: request queue/search/filter UI.
- `NexTrade/Features/Requests/RequestsListViewModel.swift`: request queue state/filtering.
- `NexTrade/Features/Requests/RequestDetailView.swift`: case detail.
- `NexTrade/Shared/AppDesignSystem.swift`: colors/tokens.
- `NexTrade/Shared/AppLocalization.swift`: Việt/Anh copy.

## Gap và vấn đề còn tồn tại

- Không có backend, authentication, persistence hay networking; request mất sau khi restart app.
- Không có seeded/sample requests, nên dashboard và queue khởi đầu ở empty state.
- Request detail chưa có timeline xử lý thực tế, cập nhật case theo thời gian, file attachment, báo giá hoặc supplier comparison.
- Chưa có Product Opportunities và Sourcing Packages, dù đây là hai flow quan trọng trong roadmap Phase 1.
- Profile contact đang là placeholder; chưa có action gọi/email/Zalo thật.
- Chưa có automated tests, analytics, error reporting hoặc accessibility audit đầy đủ.
- Cần kiểm tra trực quan trên simulator/device khi môi trường simulator khả dụng.

## Task tiếp theo nên làm

Ưu tiên: nâng `RequestDetailView` thành case workspace có timeline trạng thái và khối “Cập nhật từ NexTrade” có timestamp. Điều này giúp user hiểu yêu cầu đang được xử lý đến đâu và hỗ trợ chiến lược tạo niềm tin của NexTrade.

Sau đó: thiết kế `Sourcing Packages` với phạm vi dịch vụ, giá, SLA và CTA lead phù hợp; không biến nó thành marketplace.

## Cập nhật hiện tại

Ngày 2026-06-20: tạo bộ nhớ dự án cố định (`AGENTS.md`, `PROJECT_CONTEXT.md`, `TASK_LOG.md`) sau khi inspect repo. Không thay đổi code ứng dụng hoặc refactor.
