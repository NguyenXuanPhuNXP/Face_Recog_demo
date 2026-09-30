/*import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class StorageService {
  // Key mới: lưu toàn bộ danh sách user
  static const String usersKey = 'users';

  // User đang được sử dụng / đăng nhập hiện tại
  static const String currentUserIdKey = 'current_user_id';

  // Các key cũ - giữ lại để migrate dữ liệu cũ
  static const String userIdKey = 'user_id';
  static const String passwordKey = 'password';
  static const String fullNameKey = 'full_name';
  static const String embeddingKey = 'face_embedding';

  // ============================================================
  // LẤY DANH SÁCH TẤT CẢ USER
  // ============================================================

  Future<List<UserModel>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(usersKey);

    // Nếu chưa có danh sách users mới
    if (data == null) {
      await _migrateOldUser();

      final migratedData = prefs.getString(usersKey);

      if (migratedData == null) {
        return [];
      }

      return _decodeUsers(migratedData);
    }

    return _decodeUsers(data);
  }

  // ============================================================
  // GIẢI MÃ DANH SÁCH USER
  // ============================================================

  List<UserModel> _decodeUsers(String data) {
    try {
      final decoded = jsonDecode(data);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .map(
            (item) => UserModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // LƯU DANH SÁCH USER
  // ============================================================

  Future<void> _saveUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();

    final data = users
        .map((user) => user.toJson())
        .toList();

    await prefs.setString(
      usersKey,
      jsonEncode(data),
    );
  }

  // ============================================================
  // ĐĂNG KÝ / LƯU USER
  // ============================================================

  Future<void> saveUser({
    required String userId,
    required String password,
    required String fullName,
    required List<double> embedding,
  }) async {
    final users = await getUsers();

    final newUser = UserModel(
      userId: userId,
      password: password,
      fullName: fullName,
      faceEmbedding: embedding,
    );

    // Tìm user đã tồn tại
    final index = users.indexWhere(
          (user) => user.userId == userId,
    );

    if (index >= 0) {
      // Nếu đã tồn tại → cập nhật
      users[index] = newUser;
    } else {
      // Nếu chưa tồn tại → thêm mới
      users.add(newUser);
    }

    await _saveUsers(users);

    // Sau khi đăng ký, đặt user này làm current user
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      currentUserIdKey,
      userId,
    );
  }

  // ============================================================
  // TÌM USER THEO ID
  // ============================================================

  Future<UserModel?> getUser(
      String userId,
      ) async {
    final users = await getUsers();

    try {
      return users.firstWhere(
            (user) => user.userId == userId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // LẤY USER HIỆN TẠI
  // ============================================================

  Future<UserModel?> getCurrentUser() async {
    final userId = await getUserId();

    if (userId == null) {
      return null;
    }

    return getUser(userId);
  }

  // ============================================================
  // ĐẶT USER HIỆN TẠI
  // ============================================================

  Future<void> setCurrentUser(
      String userId,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      currentUserIdKey,
      userId,
    );
  }

  // ============================================================
  // LẤY TÊN USER HIỆN TẠI
  // ============================================================

  Future<String?> getName() async {
    final user = await getCurrentUser();

    return user?.fullName;
  }

  // ============================================================
  // KIỂM TRA CÓ USER HAY CHƯA
  // ============================================================

  Future<bool> hasUser() async {
    final users = await getUsers();

    return users.isNotEmpty;
  }

  // ============================================================
  // LẤY EMBEDDING
  //
  // Nếu truyền userId:
  //     getEmbedding('user001')
  //
  // Nếu không truyền:
  //     lấy embedding của current user
  // ============================================================

  Future<List<double>?> getEmbedding([
    String? userId,
  ]) async {
    UserModel? user;

    if (userId != null) {
      user = await getUser(userId);
    } else {
      user = await getCurrentUser();
    }

    return user?.faceEmbedding;
  }

  // ============================================================
  // LẤY USER ID HIỆN TẠI
  // ============================================================

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(
      currentUserIdKey,
    );
  }

  // ============================================================
  // LẤY PASSWORD CỦA USER HIỆN TẠI
  // ============================================================

  Future<String?> getPassword() async {
    final user = await getCurrentUser();

    return user?.password;
  }

  // ============================================================
  // XÓA USER
  // ============================================================

  Future<void> deleteUser(
      String userId,
      ) async {
    final users = await getUsers();

    users.removeWhere(
          (user) => user.userId == userId,
    );

    await _saveUsers(users);

    final prefs = await SharedPreferences.getInstance();

    final currentUserId = prefs.getString(
      currentUserIdKey,
    );

    if (currentUserId == userId) {
      await prefs.remove(currentUserIdKey);
    }
  }

  // ============================================================
  // XÓA TOÀN BỘ USER
  // ============================================================

  Future<void> clearAllUsers() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(usersKey);
    await prefs.remove(currentUserIdKey);
  }

  // ============================================================
  // MIGRATE DỮ LIỆU CŨ
  //
  // Nếu app trước đây đã lưu:
  //
  // user_id
  // password
  // full_name
  // face_embedding
  //
  // thì chuyển sang:
  //
  // users = [UserModel]
  // ============================================================

  Future<void> _migrateOldUser() async {
    final prefs = await SharedPreferences.getInstance();

    final oldUserId = prefs.getString(userIdKey);
    final oldPassword = prefs.getString(passwordKey);
    final oldFullName = prefs.getString(fullNameKey);
    final oldEmbeddingData = prefs.getString(embeddingKey);

    // Không có dữ liệu cũ
    if (oldUserId == null ||
        oldPassword == null ||
        oldFullName == null ||
        oldEmbeddingData == null) {
      return;
    }

    try {
      final decodedEmbedding = jsonDecode(
        oldEmbeddingData,
      );

      final embedding = List<double>.from(
        (decodedEmbedding as List).map(
              (e) => (e as num).toDouble(),
        ),
      );

      final oldUser = UserModel(
        userId: oldUserId,
        password: oldPassword,
        fullName: oldFullName,
        faceEmbedding: embedding,
      );

      await _saveUsers([
        oldUser,
      ]);

      await prefs.setString(
        currentUserIdKey,
        oldUserId,
      );
    } catch (_) {
      // Nếu dữ liệu cũ bị lỗi thì bỏ qua migration
    }
  }
}

 */

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class StorageService {
  static const String usersKey = 'users';
  static const String currentUserIdKey = 'current_user_id';

  // ============================================================
  // LẤY TẤT CẢ USER
  // ============================================================

  Future<List<UserModel>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(usersKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(data);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .map(
            (item) => UserModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (e) {
      print('Lỗi đọc users: $e');
      return [];
    }
  }

  // ============================================================
  // LƯU TẤT CẢ USER
  // ============================================================

  Future<void> _saveUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = users
        .map((user) => user.toJson())
        .toList();

    final jsonString = jsonEncode(jsonList);

    print('===== SAVE USERS =====');
    print('Số user: ${users.length}');
    print(jsonString);

    await prefs.setString(
      usersKey,
      jsonString,
    );
  }

  // ============================================================
  // ĐĂNG KÝ USER
  // ============================================================

  Future<void> saveUser({
    required String userId,
    required String password,
    required String fullName,
    required List<double> embedding,
  }) async {
    final users = await getUsers();

    print('===== BEFORE SAVE =====');
    print('Số user hiện tại: ${users.length}');

    for (final user in users) {
      print(
        '${user.userId} - ${user.fullName}',
      );
    }

    final newUser = UserModel(
      userId: userId,
      password: password,
      fullName: fullName,
      faceEmbedding: embedding,
    );

    final index = users.indexWhere(
          (user) => user.userId == userId,
    );

    if (index >= 0) {
      // User đã tồn tại → cập nhật
      users[index] = newUser;

      print(
        'Cập nhật user: $userId',
      );
    } else {
      // User mới → thêm vào danh sách
      users.add(newUser);

      print(
        'Thêm user mới: $userId',
      );
    }

    await _saveUsers(users);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      currentUserIdKey,
      userId,
    );

    print('===== AFTER SAVE =====');
    print('Tổng user: ${users.length}');
  }

  // ============================================================
  // LẤY USER THEO USER ID
  // ============================================================

  Future<UserModel?> getUser(
      String userId,
      ) async {
    final users = await getUsers();

    for (final user in users) {
      if (user.userId == userId) {
        return user;
      }
    }

    return null;
  }

  // ============================================================
  // LẤY USER HIỆN TẠI
  // ============================================================

  Future<UserModel?> getCurrentUser() async {
    final userId = await getUserId();

    if (userId == null) {
      return null;
    }

    return getUser(userId);
  }

  // ============================================================
  // LẤY USER ID HIỆN TẠI
  // ============================================================

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(
      currentUserIdKey,
    );
  }

  // ============================================================
  // ĐẶT USER HIỆN TẠI
  // ============================================================

  Future<void> setCurrentUser(
      String userId,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      currentUserIdKey,
      userId,
    );
  }

  // ============================================================
  // LẤY TÊN USER HIỆN TẠI
  // ============================================================

  Future<String?> getName() async {
    final user = await getCurrentUser();

    return user?.fullName;
  }

  // ============================================================
  // LẤY PASSWORD USER HIỆN TẠI
  // ============================================================

  Future<String?> getPassword() async {
    final user = await getCurrentUser();

    return user?.password;
  }

  // ============================================================
  // LẤY EMBEDDING
  // ============================================================

  Future<List<double>?> getEmbedding([
    String? userId,
  ]) async {
    UserModel? user;

    if (userId != null) {
      user = await getUser(userId);
    } else {
      user = await getCurrentUser();
    }

    return user?.faceEmbedding;
  }

  // ============================================================
  // KIỂM TRA CÓ USER
  // ============================================================

  Future<bool> hasUser() async {
    final users = await getUsers();

    return users.isNotEmpty;
  }

  // ============================================================
  // XÓA 1 USER
  // ============================================================

  Future<void> deleteUser(
      String userId,
      ) async {
    final users = await getUsers();

    users.removeWhere(
          (user) => user.userId == userId,
    );

    await _saveUsers(users);

    final currentUserId = await getUserId();

    if (currentUserId == userId) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(
        currentUserIdKey,
      );
    }
  }

  // ============================================================
  // XÓA TẤT CẢ USER
  // ============================================================

  Future<void> clearAllUsers() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(usersKey);
    await prefs.remove(currentUserIdKey);
  }
}