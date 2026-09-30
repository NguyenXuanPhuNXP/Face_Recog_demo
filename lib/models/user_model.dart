class UserModel {
  final String userId;
  final String password;
  final String fullName;
  final List<double> faceEmbedding;

  UserModel({
    required this.userId,
    required this.password,
    required this.fullName,
    required this.faceEmbedding,
  });

  /// Chuyển UserModel thành Map để lưu vào JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'password': password,
      'fullName': fullName,
      'faceEmbedding': faceEmbedding,
    };
  }

  /// Tạo UserModel từ dữ liệu JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      password: json['password'] as String,
      fullName: json['fullName'] as String,
      faceEmbedding: List<double>.from(
        (json['faceEmbedding'] as List).map(
              (e) => (e as num).toDouble(),
        ),
      ),
    );
  }
}