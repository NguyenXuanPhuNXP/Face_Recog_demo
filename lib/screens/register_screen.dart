import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import 'face_camera_screen.dart';

class RegisterScreen
    extends StatefulWidget {

  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final userIdController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final nameController =
  TextEditingController();

  final StorageService
  _storage =
  StorageService();

  Future<void> _register() async {

    final userId =
    userIdController.text.trim();

    final password =
    passwordController.text.trim();

    final name =
    nameController.text.trim();

    if (userId.isEmpty ||
        password.isEmpty ||
        name.isEmpty) {

      _showMessage(
        'Vui lòng nhập đầy đủ thông tin',
      );

      return;
    }

    final embedding =
    await Navigator.push<List<double>>(
      context,

      MaterialPageRoute(
        builder: (_) =>
        const FaceCameraScreen(),
      ),
    );

    if (embedding == null) {
      return;
    }

    await _storage.saveUser(
      userId: userId,
      password: password,
      fullName: name,
      embedding: embedding,
    );

    if (!mounted) {
      return;
    }

    _showMessage(
      'Đăng ký thành công!',
    );

    Navigator.pop(context);
  }

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {

    userIdController.dispose();
    passwordController.dispose();
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Đăng ký'),
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller:
              userIdController,

              decoration:
              const InputDecoration(
                labelText:
                'User ID',
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            TextField(
              controller:
              nameController,

              decoration:
              const InputDecoration(
                labelText:
                'Họ và tên',
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            TextField(
              controller:
              passwordController,

              obscureText: true,

              decoration:
              const InputDecoration(
                labelText:
                'Password',
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width:
              double.infinity,

              child:
              ElevatedButton(
                onPressed:
                _register,

                child:
                const Text(
                  'ĐĂNG KÝ',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}