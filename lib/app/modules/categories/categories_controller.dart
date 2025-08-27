import 'package:get/get.dart';
import '../../data/services/category_service.dart';
import '../../data/models/category.dart';

class CategoriesController extends GetxController {
  final CategoryService _categoryService = CategoryService();
  
  final categories = <Category>[].obs;
  final isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final categoryList = await _categoryService.getAllCategories();
      categories.assignAll(categoryList);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(Category category) async {
    try {
      await _categoryService.deleteCategory(category.id!);
      categories.remove(category);
      Get.snackbar(
        'Sukses',
        'Kategori berhasil dihapus',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete category: $e');
    }
  }
}
