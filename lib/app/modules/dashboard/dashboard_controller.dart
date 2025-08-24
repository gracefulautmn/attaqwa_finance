import 'package:get/get.dart';
import '../../data/models/transaction_model.dart';

class DashboardController extends GetxController {
  // Reactive variables for dashboard data
  final RxDouble cashBalance = 0.0.obs;
  final RxDouble monthlyIncome = 0.0.obs;
  final RxDouble monthlyExpenses = 0.0.obs;
  final RxList<FinanceTransaction> recentTransactions = <FinanceTransaction>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() {
    isLoading.value = true;
    
    // Simulate loading data - replace with actual API calls
    Future.delayed(const Duration(milliseconds: 800), () {
      // Mock data for demonstration
      cashBalance.value = 12500000.0; // 12.5 million IDR
      monthlyIncome.value = 8500000.0; // 8.5 million IDR
      monthlyExpenses.value = 3200000.0; // 3.2 million IDR
      
      // Mock recent transactions
      recentTransactions.value = [
        FinanceTransaction(
          id: '1',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          description: 'Donasi Jumat',
          createdBy: 'Admin Masjid',
        ),
        FinanceTransaction(
          id: '2',
          date: DateTime.now().subtract(const Duration(days: 1)),
          description: 'Pembayaran Listrik',
          createdBy: 'Admin Masjid',
        ),
        FinanceTransaction(
          id: '3',
          date: DateTime.now().subtract(const Duration(days: 2)),
          description: 'Donasi Umum',
          createdBy: 'Admin Masjid',
        ),
        FinanceTransaction(
          id: '4',
          date: DateTime.now().subtract(const Duration(days: 3)),
          description: 'Pembelian Air Minum',
          createdBy: 'Admin Masjid',
        ),
        FinanceTransaction(
          id: '5',
          date: DateTime.now().subtract(const Duration(days: 4)),
          description: 'Donasi Khusus',
          createdBy: 'Admin Masjid',
        ),
      ];
      
      isLoading.value = false;
    });
  }

  void refreshData() {
    loadDashboardData();
  }

  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  String getTransactionType(String description) {
    final incomeKeywords = ['donasi', 'sumbangan', 'zakat', 'infaq'];
    final expenseKeywords = ['pembayaran', 'pembelian', 'biaya', 'tagihan'];
    
    final lowerDesc = description.toLowerCase();
    
    if (incomeKeywords.any((keyword) => lowerDesc.contains(keyword))) {
      return 'income';
    } else if (expenseKeywords.any((keyword) => lowerDesc.contains(keyword))) {
      return 'expense';
    }
    return 'other';
  }
}
