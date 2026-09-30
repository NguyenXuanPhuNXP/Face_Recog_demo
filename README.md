# face_recognition_demo

Demo nhận diện khuôn mặt
Ứng dụng sử dụng camera để thu nhận hình ảnh khuôn mặt, Google ML Kit để phát hiện khuôn mặt, MobileFaceNet để trích xuất đặc trưng khuôn mặt và Cosine Similarity để so sánh với khuôn mặt đã đăng ký.

## Công nghệ sử dụng

Framework: Flutter
Ngôn ngữ: Dart
Nền tảng: Android
Camera: Flutter Camera
Face Detection: Google ML Kit
Face Recognition: MobileFaceNet
Model format: TensorFlow Lite (.tflite)
Native bridge: Dart FFI / TensorFlow Lite C API
Face matching: Cosine Similarity
Local storage: SharedPreferences + JSON
IDE: Android Studio

## Kiến trúc hệ thống

```text
Camera
   ↓
Camera Frame
   ↓
Google ML Kit Face Detection
   ↓
Face Bounding Box
   ↓
Crop khuôn mặt
   ↓
Resize 112 × 112
   ↓
Normalize pixel
   ↓
MobileFaceNet
   ↓
Face Embedding
   ↓
Cosine Similarity
   ↓
Threshold = 0.70
   ↓
Match / Not Match

## Công nghệ sử dụng
### Yêu cầu

Cần cài đặt:

Flutter SDK
Android Studio
Android SDK
Android Emulator hoặc điện thoại Android
Git

- Kiểm tra Flutter:

flutter doctor
Clone Project
git clone https://github.com/NguyenXuanPhuNXP/Face_Recog_demo.git

- Di chuyển vào thư mục project:

cd Face_Recog_demo

- Cài đặt dependencies:

flutter pub get

- Kiểm tra thiết bị Android:

flutter devices

- Chạy ứng dụng:

flutter run
- Chạy bằng Android Studio
+ Bước 1
Mở Android Studio.

+ Bước 2
Chọn:
Open

và chọn thư mục:
Face_Recog_demo
+ Bước 3
Chờ Android Studio tải Gradle và các dependencies.

+ Bước 4
Mở Terminal trong Android Studio:
flutter pub get

+ Bước 5
Khởi động Android Emulator hoặc kết nối điện thoại Android.
Kiểm tra:
flutter devices

+ Bước 6
Chạy project:
flutter run
Hoặc nhấn nút:
Run ▶
trên Android Studio.
