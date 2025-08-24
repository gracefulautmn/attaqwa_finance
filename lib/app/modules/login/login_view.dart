import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_textfield.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masuk')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(controller: controller.emailC, label: 'Email'),
            const SizedBox(height: 12),
            CustomTextField(controller: controller.passC, label: 'Password', obscureText: true),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
              onPressed: controller.loading.value ? null : controller.login,
              child: controller.loading.value ? const CircularProgressIndicator() : const Text('Login'),
            )),
          ],
        ),
      ),
    );
  }
}
