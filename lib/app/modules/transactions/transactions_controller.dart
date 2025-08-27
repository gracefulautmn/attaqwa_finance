import 'package:get/get.dart';
import '../../data/services/transaction_service.dart';
import '../../data/models/transaction.dart';

class TransactionsController extends GetxController {
  final TransactionService _transactionService = TransactionService();
  
  final transactions = <Transaction>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 'all'.obs; 
  
  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      
      TransactionType? typeFilter;
      if (selectedFilter.value == 'income') {
        typeFilter = TransactionType.income;
      } else if (selectedFilter.value == 'expense') {
        typeFilter = TransactionType.expense;
      }
      
      final transactionList = await _transactionService.getAllTransactions(
        type: typeFilter,
        limit: 100,
      );
      transactions.assignAll(transactionList);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    loadTransactions();
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    try {
      await _transactionService.deleteTransaction(transaction.id!);
      transactions.remove(transaction);
      Get.snackbar(
        'Sukses',
        'Transaksi berhasil dihapus',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete transaction: $e');
    }
  }

  void goToAddTransaction() {
    Get.toNamed('/add-transaction')?.then((result) {
      if (result == true) {
        loadTransactions();
      }
    });
  }
}
