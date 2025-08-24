import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chart_of_accounts_controller.dart';

class ChartOfAccountsView extends GetView<ChartOfAccountsController> {
  const ChartOfAccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kode Akun (CoA)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.loading.value) return const Center(child: CircularProgressIndicator());
        if (controller.items.isEmpty) return const Center(child: Text('Belum ada akun.'));
        return ListView.separated(
          itemCount: controller.items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final a = controller.items[i];
            return ListTile(
              title: Text('${a['account_code']} - ${a['account_name']}'),
              subtitle: Text('${a['account_type']} • Normal: ${a['normal_balance']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(context, existing: a)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => controller.delete(a['id'] as String)),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _openForm(BuildContext context, {Map<String, dynamic>? existing}) {
    final codeC = TextEditingController(text: existing?['account_code']);
    final nameC = TextEditingController(text: existing?['account_name']);
    String type = existing?['account_type'] ?? 'Aset Lancar';
    String normal = existing?['normal_balance'] ?? 'Debet';

    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(runSpacing: 12, children: [
            Text(existing == null ? 'Tambah Akun' : 'Ubah Akun', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            TextField(decoration: const InputDecoration(labelText: 'Kode Akun'), controller: codeC),
            TextField(decoration: const InputDecoration(labelText: 'Nama Akun'), controller: nameC),
            DropdownButtonFormField<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: 'Aset Lancar', child: Text('Aset Lancar')),
                DropdownMenuItem(value: 'Aset Tetap', child: Text('Aset Tetap')),
                DropdownMenuItem(value: 'Pendapatan', child: Text('Pendapatan')),
                DropdownMenuItem(value: 'Beban', child: Text('Beban')),
              ],
              onChanged: (v) => type = v ?? type,
              decoration: const InputDecoration(labelText: 'Tipe Akun'),
            ),
            DropdownButtonFormField<String>(
              value: normal,
              items: const [
                DropdownMenuItem(value: 'Debet', child: Text('Debet')),
                DropdownMenuItem(value: 'Kredit', child: Text('Kredit')),
              ],
              onChanged: (v) => normal = v ?? normal,
              decoration: const InputDecoration(labelText: 'Normal Balance'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.createOrEdit(
                      id: existing?['id'] as String?,
                      code: codeC.text.trim(),
                      name: nameC.text.trim(),
                      type: type,
                      normalBalance: normal,
                    ),
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    );
  }
}
