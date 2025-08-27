import 'package:get/get.dart';

import 'package:attaqwa_finance/app/modules/auth/auth_binding.dart';
import 'package:attaqwa_finance/app/modules/auth/splash_view.dart';
import 'package:attaqwa_finance/app/modules/auth/login_view.dart';
import 'package:attaqwa_finance/app/modules/home/home_binding.dart';
import 'package:attaqwa_finance/app/modules/home/home_view.dart';
import 'package:attaqwa_finance/app/modules/add_transaction/add_transaction_binding.dart';
import 'package:attaqwa_finance/app/modules/add_transaction/add_transaction_view.dart';
import 'package:attaqwa_finance/app/modules/transactions/transactions_binding.dart';
import 'package:attaqwa_finance/app/modules/transactions/transactions_view.dart';
import 'package:attaqwa_finance/app/modules/categories/categories_binding.dart';
import 'package:attaqwa_finance/app/modules/categories/categories_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.SPLASH;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.ADD_TRANSACTION,
      page: () => const AddTransactionView(),
      binding: AddTransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.TRANSACTIONS,
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
    ),
    GetPage(
      name: AppRoutes.CATEGORIES,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
  ];
}
