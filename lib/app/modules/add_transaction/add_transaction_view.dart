import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction.dart';
import 'package:attaqwa_finance/app/modules/add_transaction/add_transaction_controller.dart';

class AddTransactionView extends GetView<AddTransactionController> {
  const AddTransactionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelector(),
              const SizedBox(height: 24),
              _buildAmountField(),
              const SizedBox(height: 24),
              _buildCategorySelector(),
              const SizedBox(height: 24),
              _buildDateSelector(),
              const SizedBox(height: 24),
              _buildDescriptionField(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Transaksi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => controller.setTransactionType(TransactionType.income),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: controller.selectedType.value == TransactionType.income
                        ? Colors.green.shade100
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: controller.selectedType.value == TransactionType.income
                          ? Colors.green
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: controller.selectedType.value == TransactionType.income
                            ? Colors.green
                            : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pemasukan',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: controller.selectedType.value == TransactionType.income
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => controller.setTransactionType(TransactionType.expense),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: controller.selectedType.value == TransactionType.expense
                        ? Colors.red.shade100
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: controller.selectedType.value == TransactionType.expense
                          ? Colors.red
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: controller.selectedType.value == TransactionType.expense
                            ? Colors.red
                            : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pengeluaran',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: controller.selectedType.value == TransactionType.expense
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jumlah',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.amountController,
          keyboardType: TextInputType.number,
          onChanged: controller.formatAmount,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Masukkan jumlah',
            prefixText: 'Rp ',
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Obx(() => InkWell(
          onTap: _showCategoryPicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                if (controller.selectedCategory.value != null) ...[
                  if (controller.selectedCategory.value!.icon != null)
                    Icon(
                      _getIconData(controller.selectedCategory.value!.icon!),
                      color: _getColor(controller.selectedCategory.value!.color),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.selectedCategory.value!.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ] else
                  const Expanded(
                    child: Text(
                      'Pilih kategori',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Obx(() => InkWell(
          onTap: _showDatePicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('dd MMMM yyyy').format(controller.selectedDate.value),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan (opsional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Tambahkan catatan...',
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isSaving.value ? null : controller.saveTransaction,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: Theme.of(Get.context!).primaryColor,
          foregroundColor: Colors.white,
        ),
        child: controller.isSaving.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Simpan Transaksi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
      ),
    ));
  }

  void _showCategoryPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Kategori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return ListTile(
                    leading: Icon(
                      _getIconData(category.icon ?? 'category'),
                      color: _getColor(category.color),
                    ),
                    title: Text(category.name),
                    onTap: () {
                      controller.setCategory(category);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      controller.setDate(date);
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'movie':
        return Icons.movie;
      case 'receipt':
        return Icons.receipt;
      case 'work':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'attach_money':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }

  Color _getColor(String? colorCode) {
    if (colorCode == null) return Colors.grey;
    try {
      return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}
