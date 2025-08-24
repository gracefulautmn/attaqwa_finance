import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('At-Taqwa Finance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MenuCard(title: 'Input Transaksi', onTap: () => Get.toNamed(AppRoutes.ADD_TX)),
            _MenuCard(title: 'Kode Akun (CoA)', onTap: () => Get.toNamed(AppRoutes.COA)),
            _MenuCard(title: 'Laporan', onTap: () => Get.toNamed(AppRoutes.REPORTS)),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _MenuCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
