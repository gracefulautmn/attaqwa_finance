import 'package:get/get.dart';
import 'chart_of_accounts_controller.dart';

class ChartOfAccountsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChartOfAccountsController>(() => ChartOfAccountsController());
  }
}
