import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/services/category_service.dart';
import '../../data/services/supabase_service.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';

class AddTransactionController extends GetxController {
  final CategoryService _categoryService = CategoryService();
  final SupabaseService _supabaseService = SupabaseService();
  
  // Form controllers
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // Observable variables
  final isLoading = false.obs;
  final isSaving = false.obs;
  final categories = <Category>[].obs;
  final selectedType = TransactionType.expense.obs;
  final selectedCategory = Rxn<Category>();
  final selectedDate = DateTime.now().obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }
  
  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
  
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final categoryList = await _categoryService.getAllCategories();
      categories.assignAll(categoryList);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat kategori: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void setTransactionType(TransactionType type) {
    selectedType.value = type;
    // Reset category when type changes
    selectedCategory.value = null;
    // Filter categories based on type if needed
    loadCategories();
  }
  
  void setCategory(Category category) {
    selectedCategory.value = category;
  }
  
  void setDate(DateTime date) {
    selectedDate.value = date;
  }
  
  void formatAmount(String value) {
    // Remove any non-digit characters
    String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanValue.isEmpty) {
      amountController.text = '';
      return;
    }
    
    // Format with thousand separators
    final formatter = NumberFormat('#,###', 'id_ID');
    final formattedValue = formatter.format(int.parse(cleanValue));
    
    amountController.value = TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
  
  double _parseAmount(String value) {
    // Remove thousand separators and convert to double
    String cleanValue = value.replaceAll(',', '').replaceAll('.', '');
    return cleanValue.isEmpty ? 0.0 : double.parse(cleanValue);
  }
  
  Future<void> saveTransaction() async {
    if (!_validateForm()) {
      return;
    }
    
    try {
      isSaving.value = true;
      
      final amount = _parseAmount(amountController.text);
      final description = descriptionController.text.trim().isEmpty 
          ? 'Transaksi ${selectedCategory.value?.name ?? 'Umum'}' 
          : descriptionController.text.trim();
      
      // Use SupabaseService method that handles the database schema correctly
      await _supabaseService.createTransactionWithCategory(
        date: selectedDate.value,
        description: description,
        categoryId: selectedCategory.value!.id.toString(),
        amount: amount,
      );
      
      Get.snackbar(
        'Sukses',
        'Transaksi berhasil ditambahkan',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.white,
      );
      
      // Return to previous screen with success result
      Get.back(result: true);
      
    } catch (e) {
      print('Transaction save error: $e'); // For debugging
      Get.snackbar(
        'Error', 
        'Gagal menyimpan transaksi: $e',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
  
  bool _validateForm() {
    if (amountController.text.isEmpty || _parseAmount(amountController.text) <= 0) {
      Get.snackbar('Validasi', 'Mohon masukkan jumlah yang valid');
      return false;
    }
    
    if (selectedCategory.value == null) {
      Get.snackbar('Validasi', 'Mohon pilih kategori');
      return false;
    }
    
    return true;
  }
}