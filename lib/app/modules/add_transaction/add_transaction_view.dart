import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_transaction_controller.dart';

class AddTransactionView extends GetView<AddTransactionController> {
  const AddTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('Tanggal Transaksi'),
              subtitle: Obx(() => Text(controller.formatDate(controller.date.value))),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.date.value,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) controller.date.value = picked;
                },
              ),
            ),
            TextField(
              controller: controller.descC,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.amountC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
            ),
            const SizedBox(height: 12),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.debitAccountId.value,
                  decoration: const InputDecoration(labelText: 'Akun Debet'),
                  items: controller.accounts
                      .map((a) => DropdownMenuItem(
                            value: a['id'] as String,
                            child: Text('${a['account_code']} - ${a['account_name']}'),
                          ))
                      .toList(),
                  onChanged: (v) => controller.debitAccountId.value = v,
                )),
            const SizedBox(height: 12),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.creditAccountId.value,
                  decoration: const InputDecoration(labelText: 'Akun Kredit'),
                  items: controller.accounts
                      .map((a) => DropdownMenuItem(
                            value: a['id'] as String,
                            child: Text('${a['account_code']} - ${a['account_name']}'),
                          ))
                      .toList(),
                  onChanged: (v) => controller.creditAccountId.value = v,
                )),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed: controller.loading.value ? null : controller.submit,
                  child: controller.loading.value
                      ? const CircularProgressIndicator()
                      : const Text('Simpan'),
                )),
          ],
        ),
      ),
    );
  }
}
