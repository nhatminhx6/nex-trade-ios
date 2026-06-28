# NexTrade Task Log

## Trạng thái hiện tại

NexTrade là SwiftUI MVP iOS 17+ với luồng sourcing end-to-end qua PocketBase local. App có splash, login buyer, TabView gồm Home/Requests/Profile, tạo sourcing request, success alert, dashboard request gần đây, request queue có search/filter, và request detail.

Theme `Modern Trade OS` đã có design system tập trung, runtime dark mode và runtime localization Việt/Anh. Session đăng nhập được lưu Keychain; request được tạo/lấy từ PocketBase và chỉ hiển thị theo ownership rule của buyer.

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

Ngày 2026-06-22: tích hợp PocketBase backend local có sẵn vào iOS app. Thêm đăng nhập buyer, session token lưu Keychain, logout, cấu hình API base URL, và `PocketBaseService` cho tạo/lấy sourcing request. Form "Gửi yêu cầu" nay tạo record `sourcing_requests` thật; thông tin tên/số điện thoại liên hệ được đồng bộ vào profile buyer trước khi gửi. Đã cập nhật `AppContainer`, `AppRootView`, `ProfileView`, model request (ID PocketBase String), project XcodeGen và Việt/Anh localization; thêm `AppUser.swift`, `KeychainStore.swift`, `PocketBaseService.swift`, `LoginView.swift`. Build simulator thành công bằng `xcodebuild`; API local đã test login → create → list → cleanup thành công.

Ngày 2026-06-22: hoàn thiện contact section của form. UI tự điền contact từ buyer đã login, kiểm tra email/số điện thoại tại chỗ và hiển thị lỗi API theo ngữ cảnh. Backend thêm migration `202606220001_request_contact_snapshot.js`: lưu `contact_name`, `contact_phone`, `contact_email` trực tiếp trên sourcing request để bảo toàn dữ liệu liên hệ theo từng case; cập nhật API/schema docs tương ứng. Build simulator thành công. Server PocketBase đang chạy từ trước khi migration được thêm, vì vậy cần restart server để migration được áp dụng trước khi test submit form mới.

Ngày 2026-06-22: tự kiểm tra end-to-end. Đã restart PocketBase trong phiên test để migration contact được apply và API test create/read/delete contact snapshot thành công. Thêm `NexTradeUITests` với luồng mở form, nhập product/contact và kiểm tra CTA; UI test chạy trên iPhone 17 Pro simulator thành công (1/1). UI test dùng launch argument debug-only để bỏ qua login/network, giúp test form ổn định; API submit được kiểm tra riêng với PocketBase thật.

Ngày 2026-06-22: sửa lỗi app không gửi được request dù backend đang chạy. Nguyên nhân: Xcode không sinh các custom `INFOPLIST_KEY_*` cần thiết, khiến build app thiếu `NSAppTransportSecurity` và iOS chặn HTTP local. Chuyển sang `NexTrade/Info.plist` thực với `NexTradeAPIBaseURL` và ATS local-development exception. Build simulator thành công, đồng thời xác nhận hai key đã có trong built app Info.plist.

Ngày 2026-06-22: hoàn thiện metadata bắt buộc cho `NexTrade/Info.plist` sau khi chuyển khỏi generated plist (`CFBundleIdentifier`, `CFBundleExecutable`, tên app, package type và version). Đây là nguyên nhân Simulator báo “Missing bundle ID” / “invalid CFBundleExecutable”. Build, cài và launch NexTrade thành công trên iPhone 17 Pro Simulator.

Ngày 2026-06-22: sửa lỗi submit báo thất bại giả. PocketBase trả record thành công sau `POST /sourcing_requests` nhưng không kèm trường `created`; client lại decode response theo `RequestRecord` yêu cầu `created`, làm request bị catch như lỗi dù record đã tạo. Các mutation giờ chỉ xác minh HTTP 2xx và không decode body không cần thiết. Live UI test với PocketBase đang chạy đã pass: mở form → submit → nhận alert thành công; record test đã được xoá khỏi backend.

Ngày 2026-06-22: thêm flow duyệt tin. Backend migration `202606220002_approved_listings.js` thêm status `approved`/`rejected` và collection public-safe `approved_listings`; trang review `http://127.0.0.1:8090/review.html` cho app admin có nút Approve/Reject. Approve tạo listing không chứa contact buyer và cập nhật request thành approved. Mobile thêm tab Khám phá hiển thị các listing đã duyệt. iOS build thành công; cần restart PocketBase để apply migration mới trước khi sử dụng review dashboard.

Ngày 2026-06-22: dashboard review dùng URL `http://127.0.0.1:8090/admin-review.html`. Session admin hiện được lưu local storage, tự khôi phục sau reload và có Sign out; không cần nhập lại credentials trừ khi token hết hạn hoặc chủ động đăng xuất.

Ngày 2026-06-22: sửa queue dashboard lỗi 400. `sourcing_requests` hiện không trả system field `created`, nên PocketBase reject `sort=-created`; bỏ server-side sort khỏi queue/dashboard và API iOS, đồng thời decode `created` optional để tương thích dữ liệu hiện tại. API queue đã xác minh trả về request `mit`; iOS build thành công.

Ngày 2026-06-22: thiết kế lại admin review dashboard (`admin-review.html`) theo hướng operations console: hierarchy rõ, header/queue count, request cards compact, metadata chips và action group cố định; responsive cho mobile. Không còn card full-width trống và action trôi.

Ngày 2026-06-22: chuyển review queue sang admin data table: columns Product/Category/Quantity/Target market/Status/Buyer contact/Actions, compact rows, status badge và phân trang server-side bằng PocketBase `page` + `perPage=10`, với Previous/Next và tổng số pending requests.

Ngày 2026-06-22: đổi ưu tiên tab mobile theo hướng sản phẩm: feed tin đã duyệt (`ApprovedListingsView`) là Trang chủ mặc định; command center/source request cũ chuyển sang tab Khám phá.

Ngày 2026-06-22: đổi tên tab command center từ “Khám phá” thành “Tìm nguồn” (EN: Source) và icon thành kính lúp để phản ánh đúng luồng tạo sourcing request.

Ngày 2026-06-22: làm mới approved listing card trên mobile theo design system Modern Trade OS: category icon, approved state capsule, title/description hierarchy và metric cells cho số lượng/thị trường; bỏ style feed generic cũ.

Ngày 2026-06-22: chuyển approved feed từ card stack sang dense list: mỗi listing là row mỏng có divider, category/status, product và metadata một dòng, giúp nhìn được nhiều item hơn trên màn hình.

Ngày 2026-06-22: rút gọn feed header từ marketing hero thành title/subtitle ngắn, ưu tiên không gian dọc cho danh sách approved listings.

Ngày 2026-06-22: đồng bộ approved listing item với request queue hiện có: AppCard trắng, status rail dọc, title/meta, status capsule, divider và verified note phía dưới.

Ngày 2026-06-23: cập nhật luồng post end-to-end để bắt buộc có loại giao dịch và thời điểm giao dịch. Form iOS có segmented control Mua/Bán và DatePicker ngày/giờ; model/API gửi `trade_intent` (`buy`/`sell`) và `needed_at` (`YYYY-MM-DD HH:mm:ss`). Request detail, admin review table và feed tin đã duyệt đều hiển thị thông tin này; khi approve, dashboard copy hai field sang listing public. Thêm migration backend `202606230001_trade_intent_and_time.js` cho `sourcing_requests` và `approved_listings`, cập nhật API/schema docs. Build iOS simulator đã thành công. Cần restart PocketBase một lần để migration được apply trước khi gửi post mới.

Ngày 2026-06-23: làm gọn visual language cho các list item trên mobile. Thêm `AppListItem` dùng góc 10pt, viền mảnh và shadow rất nhẹ; approved feed và request queue đều chuyển sang row compact hai tầng (title/status, divider, one-line metadata) theo tham chiếu operations list. Đã build, cài và kiểm tra trực quan trên iPhone 17 Pro simulator.

Ngày 2026-06-23: thêm hai tab Mua/Bán ngay trên dashboard tin đã duyệt. Tab dùng filter local theo `trade_intent`, có empty state riêng cho từng phía và không gọi lại API khi chuyển tab. Đã build, cài và kiểm tra trực quan trên iPhone 17 Pro simulator.

Ngày 2026-06-23: thiết kế lại form gửi yêu cầu theo style business invoice: một intake form liên tục thay cho các card cách xa nhau, section ngăn bằng hairline, heading gọn, field label nhỏ, input cao 44pt/nền xám nhạt/góc 10pt. Category đổi thành dropdown; phần ngân sách và ghi chú được collapse mặc định để luồng bắt buộc (giao dịch → sản phẩm → liên hệ) dễ quét hơn. Build simulator thành công.

Ngày 2026-06-23: làm lại dashboard tin đã duyệt theo style operations list: filter Mua/Bán compact kèm date-filter dropdown (Tất cả, Hôm qua, 7 ngày, 14 ngày, 1 tháng); row hiển thị sản phẩm, approved state, quantity, thị trường và ngày giao dịch. Filter chạy local theo ngày tạo listing, fallback sang ngày giao dịch cho dữ liệu tương thích. Đã build, cài và kiểm tra trực quan trên iPhone 17 Pro simulator.

Ngày 2026-06-23: tăng phân cấp cho filter dashboard: tab Mua/Bán active có fill accent tím và chữ trắng; date filter giảm font/padding để là control phụ. Đã build, cài và kiểm tra trực quan trên iPhone 17 Pro simulator.

Ngày 2026-06-23: đồng bộ trạng thái selected cho Mua/Bán trong form gửi yêu cầu với dashboard: lựa chọn active dùng accent tím/chữ trắng, inactive dùng màu phụ. Build simulator thành công.

Ngày 2026-06-23: chỉnh layout DatePicker trong form: label ngày/giờ nằm trên, compact date/time control nằm ở hàng dưới thay vì bị ép chung hàng và wrap chữ. Build simulator thành công.

Ngày 2026-06-23: rút trade scheduler về chỉ chọn ngày. DatePicker không còn giờ; submit chuẩn hóa `needed_at` về đầu ngày và các màn detail/docs hiển thị đây là ngày giao dịch, không phải timestamp. Build simulator thành công.

Ngày 2026-06-23: làm lại language/theme toolbar control: gộp thành một control góc nhỏ có divider mảnh, loại bỏ circle/capsule lồng nhau và toàn bộ shadow; ngôn ngữ có accent nhẹ, theme là icon tối giản. Đã build, cài và kiểm tra trực quan trên iPhone 17 Pro simulator.

Ngày 2026-06-23: bỏ toolbar group vì iOS tự bọc thành pill lớn. Thay bằng một menu settings icon chuẩn navigation bar; menu chứa lựa chọn ngôn ngữ và light/dark mode. Đã build, cài và kiểm tra trực quan trên iPhone 17 Pro simulator.

Ngày 2026-06-23: trả language/theme về hai nút thao tác trực tiếp. Đưa controls ra header app để tránh automatic pill của iOS toolbar; mỗi nút có surface riêng, viền mảnh và corner radius 8pt, không outer capsule/shadow. Đã build, cài và kiểm tra trực quan trên iPhone 17 Pro simulator.

Ngày 2026-06-23: bỏ authentication gate khi mở app. Guest có thể xem dashboard và các tab công khai; request history không gọi API khi chưa có session. Bấm Gửi yêu cầu trong form mới mở login sheet, sau login tự điền contact còn thiếu và tiếp tục submit request đang soạn. Cập nhật UI test guest browsing và test này đã pass (1/1); iOS build cũng pass.

Ngày 2026-06-23: đưa login gate sớm hơn tại CTA “Gửi yêu cầu tìm nguồn” trong tab Tìm nguồn. Guest bấm CTA sẽ mở login; thành công thì tự điều hướng vào form. Thêm guest launch mode cho UI tests; test guest → CTA → login sheet đã pass (1/1).

Ngày 2026-06-23: chuyển language/theme quick controls từ global app header sang riêng đầu tab Hồ sơ, tránh che/chiếm không gian của dashboard và các luồng sourcing. Build simulator thành công.

Ngày 2026-06-24: làm lại approved listing item theo hierarchy sourcing: intent/category, product, approved indicator không pill, metric quantity/market rõ ràng và date footer. Thêm `published_at` cho approved listings; dashboard admin ghi timestamp khi approve, mobile hiển thị ngày/giờ đăng cùng ngày cần giao dịch. Thêm backend migration `202606240001_listing_published_at.js`, cập nhật schema và mobile decode. Build, cài và kiểm tra trực quan trên simulator thành công. Cần restart PocketBase để apply migration; listing cũ không có timestamp sẽ chưa hiện footer date.

Ngày 2026-06-24: xác minh live backend sau restart: tạo tạm một sourcing request qua API, nhận lại `trade_intent: buy` và `needed_at: 2026-06-30 00:00:00`, sau đó xoá record test. Các approved listing cũ có field rỗng vì được tạo trước migration; listing mới sẽ nhận date khi approved.

Ngày 2026-06-24: giữ compact listing row hiện tại và thêm date footer cho record có metadata: thời gian đăng (`published_at`) và ngày cần giao dịch (`needed_at`). Dùng format ngắn phù hợp mobile `Đăng HH:mm · dd/MM` / `Cần dd/MM/yy`; đã build, cài fresh và xác nhận record mới hiển thị đủ hai mốc trên simulator.

Ngày 2026-06-24: tách category và thị trường trên approved listing row thành hai dòng riêng, bỏ inline dot separator để thông tin dễ quét hơn. Build simulator thành công.

Ngày 2026-06-24: thêm field riêng `product_description` xuyên suốt create request: TextArea trong phần Thông tin sản phẩm, Swift model/view model, payload iOS, PocketBase request/listing schema và admin approve copy. Request detail đọc/hiển thị field mới; admin table ưu tiên product description. Thêm migration `202606240002_product_description.js`, cập nhật API/schema docs. iOS build simulator thành công; cần restart PocketBase để apply migration.

Ngày 2026-06-24: chuẩn hoá text display cho approved listing row: viết hoa ký tự đầu của tên sản phẩm/thị trường và map raw category codes (`fruit`, `vegetable`, `other`) qua localization thay vì hiển thị lowercase API value. Build simulator thành công.

Ngày 2026-06-24: hiển thị `product_description` trên approved listing row khi có dữ liệu, đặt trước date footer và giới hạn hai dòng. Dùng text field plain-text ở PocketBase cho field này. Build simulator thành công.

Ngày 2026-06-24: bỏ quantity column tách rời ở approved listing row. Thị trường và số lượng giờ nằm cùng metadata line với label rõ `Số lượng: …`, tránh số không có ngữ cảnh. Build simulator thành công.

Ngày 2026-06-24: chuyển category của approved listing sang góc phải cùng hàng title; left side giữ product title và market/quantity metadata. Build simulator thành công.

Ngày 2026-06-24: thay raw metadata line `Market · Quantity: value` bằng compact detail strip có globe/market và shipping box/quantity, phân tách bằng hairline dọc. Build simulator thành công.

Ngày 2026-06-24: thêm `quantity_unit` xuyên suốt sourcing request và approved listing. Form iOS có selector đơn vị (kg, tấn, container, thùng, cái); payload/API/mobile model, admin approve copy và schema docs đều gửi/đọc field thật. Dashboard mobile giờ hiển thị số lượng kèm đơn vị (ví dụ `1000 kg`) và category được canh sát góc phải phía trên của row. Thêm migration backend `202606240003_quantity_unit.js`; iOS simulator build thành công. Cần restart PocketBase một lần để apply migration trước khi tạo post mới có đơn vị.

Ngày 2026-06-25: thêm API và UI để user sửa/xoá bài post của chính mình. `SourcingRequestServiceProtocol`, mock service và `PocketBaseService` nay có `updateRequest` bằng `PATCH /sourcing_requests/{id}` và `deleteRequest` bằng `DELETE /sourcing_requests/{id}`; form tạo yêu cầu được reuse thành edit mode với dữ liệu prefill và nút “Lưu thay đổi”. Màn chi tiết yêu cầu có menu Sửa bài post / Xoá bài post, xoá có confirm alert và sửa xong tự refresh detail. Cập nhật localization Việt/Anh và docs API/schema backend để mô tả endpoint update/delete. Build iOS simulator thành công. Không cần migration mới vì rule hiện tại đã cho request owner update/delete record của mình.

Ngày 2026-06-25: chỉnh UX sửa/xoá bài post trên màn chi tiết theo hướng rõ hơn: bỏ menu popup 3 chấm, đưa nút “Sửa” trực tiếp lên góc phải navigation bar và đặt nút “Xoá bài post” full-width màu đỏ ở cuối màn. Build iOS simulator thành công.

Ngày 2026-06-25: kiểm tra lý do tab Yêu cầu vẫn hiện 6 bài sau khi xoá dữ liệu hôm trước. API buyer demo vẫn còn 6 record trong `sourcing_requests`, toàn bộ đang có status raw `approved`; app cũ chưa map `approved/rejected` nên hiển thị sai thành “Mới”, và các record cũ thiếu system field `created` nên fallback ra `1 Jan 07:06`. Đã thêm trạng thái `approved/rejected` vào `SourcingRequestStatus`, map từ API đúng sang “Đã duyệt/Từ chối”, và request row fallback sang ngày cần giao dịch khi thiếu ngày tạo. Build iOS simulator thành công. Chưa xoá DB thật trong lượt này.

Ngày 2026-06-25: cập nhật flow moderation khi user sửa bài đã duyệt. Mobile `PATCH` request giờ luôn đưa `status` về `submitted`; thông báo sửa bài nói rõ bài chờ NexTrade duyệt lại. Backend thêm migration `202606250001_reapproval_visibility.js`: public `approved_listings` chỉ list/view được khi source request còn `status = approved`, admin vẫn thấy toàn bộ. Admin review page khi approve lại sẽ xoá listing cũ của request trước khi publish bản mới; reject cũng xoá listing cũ để không còn bài stale. Cập nhật API/schema docs. iOS simulator build thành công. Cần restart PocketBase để apply migration rule mới.

Ngày 2026-06-25: sửa bug dashboard mobile vẫn show bài vừa edit dù request đã quay lại `submitted`. Nguyên nhân là `ApprovedListingsView` giữ danh sách đã load trong memory và `.task` không reload khi quay lại tab; đồng thời API client chưa filter cứng theo trạng thái request gốc. `fetchApprovedListings()` giờ query `approved_listings` với `filter=request.status='approved'`; dashboard reload lại khi view xuất hiện và khi selected tab chuyển về Home. Build iOS simulator thành công.

Ngày 2026-06-25: sửa tiếp bug approve lại xong dashboard không show. PocketBase không trả kết quả cho filter relation `request.status='approved'` trên `approved_listings` như kỳ vọng, dù request gốc đã approved. Revert mobile `fetchApprovedListings()` về list public bình thường; khi buyer edit request, mobile sẽ set request về `submitted` rồi xoá các `approved_listings` liên quan để unpublish listing cũ. Thêm backend migration `202606250002_owner_unpublish_listing.js` cho phép request owner xoá approved listing của request mình; admin vẫn có quyền xoá. Docs API/schema cập nhật theo cơ chế unpublish bằng delete listing. Build iOS simulator thành công. Cần restart PocketBase để apply rule delete mới.

Gap còn lại: cấu hình hiện trỏ `http://127.0.0.1:8090/api/` để chạy simulator local và mở ATS cho local development. Trước khi phát hành hoặc test máy thật, đổi `NexTradeAPIBaseURL` sang backend HTTPS/LAN phù hợp và siết lại ATS; cần thêm đăng ký tài khoản, refresh/expiry token và test UI trên simulator/device.
