import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../chart_of_accounts/chart_of_accounts_controller.dart';
import 'financial_reports_controller.dart';

class FinancialReportsView extends GetView<FinancialReportsController> {
  const FinancialReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita butuh daftar akun untuk pilih Buku Besar
    final coa = Get.put(ChartOfAccountsController(), permanent: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Keuangan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: _DateTile(
                label: 'Mulai',
                date: controller.start.value,
                onPick: (d) => controller.start.value = d,
              )),
              const SizedBox(width: 12),
              Expanded(child: _DateTile(
                label: 'Selesai',
                date: controller.end.value,
                onPick: (d) => controller.end.value = d,
              )),
            ]),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.loading.value ? null : controller.generateGeneralJournal,
              child: const Text('Export Jurnal Umum (PDF)'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(labelText: 'Akun untuk Buku Besar'),
                    items: coa.items.map((a) => DropdownMenuItem(
                      value: a, child: Text('${a['account_code']} - ${a['account_name']}'))).toList(),
                    onChanged: (v) => _selectedAccount = v,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: controller.loading.value || _selectedAccount == null
                      ? null
                      : () => controller.generateGeneralLedger(
                            accountId: _selectedAccount!['id'] as String,
                            accountInfo: _selectedAccount!,
                          ),
                  child: const Text('Export Buku Besar (PDF)'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: controller.loading.value ? null : controller.generateActivityStatement,
              child: const Text('Export Laporan Aktivitas (PDF)'),
            ),
          ],
        )),
      ),
    );
  }
}

Map<String, dynamic>? _selectedAccount;

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  const _DateTile({required this.label, required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surface,
      title: Text(label),
      subtitle: Text('${date.day.toString().padLeft(2,'0')}-${date.month.toString().padLeft(2,'0')}-${date.year}'),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_month),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) onPick(picked);
        },
      ),
    );
  }
}
