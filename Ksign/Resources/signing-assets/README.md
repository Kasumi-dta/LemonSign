# Hướng dẫn nhúng chứng chỉ mặc định vào Ksign

Nếu bạn muốn Ksign tự động nhận diện và nạp sẵn chứng chỉ khi mở ứng dụng lần đầu (không cần người dùng phải tự tải và import file thủ công):

1. Tạo một thư mục con bên trong thư mục này với tên bất kỳ (ví dụ: MyCert).
2. Bỏ 3 tệp sau vào thư mục con đó:
   - cert.p12 : Tệp chứng chỉ Apple Developer / Distribution (.p12)
   - cert.mobileprovision : Tệp hồ sơ cấp phép (.mobileprovision)
   - cert.txt : Tệp văn bản chứa mật khẩu của file p12 (nếu không có mật khẩu thì để tệp trống hoặc gõ mật khẩu vào đây)

Cấu trúc ví dụ:
signing-assets/
└── Khoindvn/
    ├── cert.p12
    ├── cert.mobileprovision
    └── cert.txt

Lưu ý: Nếu không nhúng sẵn ở đây, người dùng vẫn có thể import chứng chỉ bất kỳ lúc nào trực tiếp trong ứng dụng tại mục: Cài đặt (Settings) -> Chứng chỉ (Certificates).
