/*import 'package:flutter/material.dart';

import '../services/face_match_service.dart';
import '../services/storage_service.dart';
import 'face_camera_screen.dart';
import 'welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userIdController = TextEditingController();

  final passwordController = TextEditingController();

  final StorageService _storage = StorageService();

  final FaceMatchService _matcher = FaceMatchService();

  Future<void> _login() async {
    final userId = userIdController.text.trim();

    final password = passwordController.text.trim();

    final storedUserId = await _storage.getUserId();

    final storedPassword = await _storage.getPassword();

    if (userId != storedUserId || password != storedPassword) {
      _showMessage(
        'UserID hoặc Password không đúng',
      );

      return;
    }

    final registeredEmbedding = await _storage.getEmbedding();

    if (registeredEmbedding == null) {
      _showMessage(
        'Tài khoản chưa đăng ký khuôn mặt',
      );

      return;
    }

    final currentEmbedding = await Navigator.push<List<double>>(
      context,
      MaterialPageRoute(
        builder: (_) => const FaceCameraScreen(),
      ),
    );

    if (currentEmbedding == null) {
      return;
    }

    final similarity = _matcher.cosineSimilarity(
      registeredEmbedding,
      currentEmbedding,
    );

    debugPrint(
      'Similarity = $similarity',
    );

    final matched = similarity >= 0.70;

    if (!mounted) {
      return;
    }

    if (matched) {
      final name = await _storage.getName();

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WelcomeScreen(
            name: name ?? 'Bạn',
          ),
        ),
      );
    } else {
      _showMessage(
        '❌ Khuôn mặt không khớp',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    userIdController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đăng nhập',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                child: const Text(
                  'ĐĂNG NHẬP',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 */

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/face_match_service.dart';
import '../services/storage_service.dart';
import 'face_camera_screen.dart';
import 'welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userIdController = TextEditingController();

  final passwordController = TextEditingController();

  final StorageService _storage = StorageService();

  final FaceMatchService _matcher = FaceMatchService();

  Future<void> _login() async {
    final userId = userIdController.text.trim();

    final password = passwordController.text.trim();

    // ============================================================
    // 1. KIỂM TRA INPUT
    // ============================================================

    if (userId.isEmpty || password.isEmpty) {
      _showMessage(
        'Vui lòng nhập User ID và Password',
      );

      return;
    }

    // ============================================================
    // 2. TÌM USER TRONG TOÀN BỘ DANH SÁCH
    // ============================================================

    final users = await _storage.getUsers();

    UserModel? user;

    for (final item in users) {
      if (item.userId == userId) {
        user = item;
        break;
      }
    }

    // Không tìm thấy User ID
    if (user == null) {
      _showMessage(
        'UserID hoặc Password không đúng',
      );

      return;
    }

    // ============================================================
    // 3. KIỂM TRA PASSWORD
    // ============================================================

    if (user.password != password) {
      _showMessage(
        'UserID hoặc Password không đúng',
      );

      return;
    }

    // ============================================================
    // 4. KIỂM TRA EMBEDDING
    // ============================================================

    final registeredEmbedding = user.faceEmbedding;

    if (registeredEmbedding.isEmpty) {
      _showMessage(
        'Tài khoản chưa đăng ký khuôn mặt',
      );

      return;
    }

    // ============================================================
    // 5. ĐẶT USER ĐANG ĐĂNG NHẬP LÀ CURRENT USER
    // ============================================================

    await _storage.setCurrentUser(
      user.userId,
    );

    // ============================================================
    // 6. MỞ CAMERA ĐỂ NHẬN DIỆN KHUÔN MẶT
    // ============================================================

    final currentEmbedding =
    await Navigator.push<List<double>>(
      context,
      MaterialPageRoute(
        builder: (_) => const FaceCameraScreen(),
      ),
    );

    if (currentEmbedding == null) {
      return;
    }

    // ============================================================
    // 7. SO SÁNH KHUÔN MẶT
    // ============================================================

    final similarity = _matcher.cosineSimilarity(
      registeredEmbedding,
      currentEmbedding,
    );

    debugPrint(
      'User: ${user.userId}',
    );

    debugPrint(
      'Name: ${user.fullName}',
    );

    debugPrint(
      'Similarity = $similarity',
    );

    // ============================================================
    // 8. KIỂM TRA THRESHOLD
    // ============================================================

    const threshold = 0.70;

    final matched = similarity >= threshold;

    if (!mounted) {
      return;
    }

    // ============================================================
    // 9. ĐĂNG NHẬP THÀNH CÔNG
    // ============================================================

    if (matched) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WelcomeScreen(
            name: user!.fullName,
          ),
        ),
      );
    } else {
      // ==========================================================
      // 10. KHUÔN MẶT KHÔNG KHỚP
      // ==========================================================

      _showMessage(
        '❌ Khuôn mặt không khớp',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    userIdController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đăng nhập',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                child: const Text(
                  'ĐĂNG NHẬP',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}