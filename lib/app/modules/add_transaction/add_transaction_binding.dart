import 'package:get/get.dart';
import 'package:attaqwa_finance/app/modules/add_transaction/add_transaction_controller.dart';

class AddTransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddTransactionController>(
      () => AddTransactionController(),
    );
  }
}