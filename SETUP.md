# Hướng dẫn cấu hình và chạy ứng dụng

## Bước 1: Cài đặt dependencies

```bash
cd barber_frontend
flutter pub get
```

## Bước 2: Cấu hình API Base URL

Mở file `lib/config/api_config.dart` và cập nhật địa chỉ backend:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL:8080';
```

- Nếu chạy trên Android emulator: dùng `http://10.0.2.2:8080`
- Nếu chạy trên iOS simulator: dùng `http://localhost:8080`
- Nếu chạy trên thiết bị thật: dùng IP máy tính của bạn, ví dụ `http://192.168.1.100:8080`

## Bước 3: Chạy ứng dụng

```bash
flutter run
```

## Cấu trúc dự án

```
lib/
├── config/          # Cấu hình API
├── models/          # Data models
├── providers/       # State management (Provider)
├── screens/         # Các màn hình
├── services/        # API services
├── theme/           # Theme và styling
└── main.dart        # Entry point
```

## Tính năng đã triển khai

✅ Đăng ký / Đăng nhập
✅ Xem danh sách dịch vụ
✅ Xem danh sách thợ cắt tóc
✅ Đặt lịch hẹn
✅ Xem lịch hẹn của tôi
✅ Hủy lịch hẹn
✅ Quản lý profile

## Ghi chú

- Ứng dụng sử dụng Provider cho state management
- Token authentication được lưu trong SharedPreferences
- Cần đảm bảo backend đang chạy và có CORS cho phép frontend kết nối

