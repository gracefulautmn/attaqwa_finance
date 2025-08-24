import 'package:get/get.dart';
import 'financial_reports_controller.dart';

class FinancialReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FinancialReportsController>(() => FinancialReportsController());
  }
}
