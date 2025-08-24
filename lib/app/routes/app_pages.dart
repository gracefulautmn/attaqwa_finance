import 'package:get/get.dart';

import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/dashboard/dashboard_binding.dart';
import '../modules/dashboard/dashboard_view.dart';
import '../modules/add_transaction/add_transaction_binding.dart';
import '../modules/add_transaction/add_transaction_view.dart';
import '../modules/chart_of_accounts/chart_of_accounts_binding.dart';
import '../modules/chart_of_accounts/chart_of_accounts_view.dart';
import '../modules/financial_reports/financial_reports_binding.dart';
import '../modules/financial_reports/financial_reports_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.SPLASH;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.ADD_TX,
      page: () => const AddTransactionView(),
      binding: AddTransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.COA,
      page: () => const ChartOfAccountsView(),
      binding: ChartOfAccountsBinding(),
    ),
    GetPage(
      name: AppRoutes.REPORTS,
      page: () => const FinancialReportsView(),
      binding: FinancialReportsBinding(),
    ),
  ];
}
