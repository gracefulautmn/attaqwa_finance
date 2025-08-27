import 'package:get/get.dart';
import '../../data/services/transaction_service.dart';
import '../../data/models/transaction.dart';

class HomeController extends GetxController {
  final TransactionService _transactionService = TransactionService();
  
  final isLoading = false.obs;
  final transactions = <Transaction>[].obs;
  final summary = {}.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      final recentTransactions = await _transactionService.getAllTransactions(
        limit: 10,
      );
      transactions.assignAll(recentTransactions);
      
      final summaryData = await _transactionService.getSummary();
      summary.assignAll(summaryData);
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }

  void goToAddTransaction() {
    Get.toNamed('/add-transaction');
  }

  void goToTransactionHistory() {
    Get.toNamed('/transactions');
  }

  void goToCategories() {
    Get.toNamed('/categories');
  }
}
