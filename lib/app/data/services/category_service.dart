import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

class CategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .order('name');

      return (response as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<Category> createCategory(Category category) async {
    try {
      final response = await _supabase
          .from('categories')
          .insert(category.toJson())
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<Category> updateCategory(Category category) async {
    try {
      final response = await _supabase
          .from('categories')
          .update({
            'name': category.name,
            'icon': category.icon,
            'color': category.color,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', category.id!)
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _supabase
          .from('categories')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
