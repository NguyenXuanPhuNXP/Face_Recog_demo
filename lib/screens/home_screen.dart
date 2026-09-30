import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen
    extends StatelessWidget {

  const HomeScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Face Recognition Demo',
        ),
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.face,
              size: 100,
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width:
              double.infinity,

              child:
              ElevatedButton(
                onPressed: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                      const RegisterScreen(),
                    ),
                  );
                },

                child:
                const Text(
                  'ĐĂNG KÝ',
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            SizedBox(
              width:
              double.infinity,

              child:
              ElevatedButton(
                onPressed: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                      const LoginScreen(),
                    ),
                  );
                },

                child:
                const Text(
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