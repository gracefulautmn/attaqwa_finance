import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CircularProgressIndicator();
          }
          if (controller.hasError.value) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.errorMessage.value, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.retryConnection,
                  child: const Text('Coba Lagi'),
                )
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }
}
