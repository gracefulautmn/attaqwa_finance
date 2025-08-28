import 'package:flutter/material.dart';
import 'package:attaqwa_finance/models/category.dart';
import 'package:attaqwa_finance/services/supabase_service.dart';
import 'package:attaqwa_finance/theme/app_theme.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Category> _incomeCategories = [];
  List<Category> _expenseCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final incomeCategories = await SupabaseService.getCategories('Pemasukan');
      final expenseCategories = await SupabaseService.getCategories('Pengeluaran');

      setState(() {
        _incomeCategories = incomeCategories;
        _expenseCategories = expenseCategories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Gagal memuat kategori: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cileungsi Indah'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: 'Pemasukan'),
            Tab(text: 'Pengeluaran'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(_incomeCategories, 'Pemasukan'),
                _buildCategoryList(_expenseCategories, 'Pengeluaran'),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, String type) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada kategori $type',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap tombol + untuk menambah kategori',
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryItem(categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    final isIncome = category.type == 'Pemasukan';
    final color = isIncome ? AppTheme.accentIncome : AppTheme.accentExpense;
    final icon = isIncome ? Icons.trending_up : Icons.trending_down;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(category.type),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditCategoryDialog(category);
            } else if (value == 'delete') {
              _confirmDeleteCategory(category);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    String selectedType = _tabController.index == 0 ? 'Pemasukan' : 'Pengeluaran';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                hintText: 'Masukkan nama kategori',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Jenis',
              ),
              items: const [
                DropdownMenuItem(value: 'Pemasukan', child: Text('Pemasukan')),
                DropdownMenuItem(value: 'Pengeluaran', child: Text('Pengeluaran')),
              ],
              onChanged: (value) {
                selectedType = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama kategori tidak boleh kosong')),
                );
                return;
              }

              Navigator.pop(context);
              await _addCategory(nameController.text.trim(), selectedType);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    final nameController = TextEditingController(text: category.name);
    String selectedType = category.type;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Jenis',
              ),
              items: const [
                DropdownMenuItem(value: 'Pemasukan', child: Text('Pemasukan')),
                DropdownMenuItem(value: 'Pengeluaran', child: Text('Pengeluaran')),
              ],
              onChanged: (value) {
                selectedType = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama kategori tidak boleh kosong')),
                );
                return;
              }

              Navigator.pop(context);
              await _updateCategory(category, nameController.text.trim(), selectedType);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCategory(category);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentExpense,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory(String name, String type) async {
    try {
      final userId = SupabaseService.currentUser!.id;
      final category = Category(
        userId: userId,
        name: name,
        type: type,
        createdAt: DateTime.now(),
      );

      await SupabaseService.createCategory(category);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori berhasil ditambahkan')),
      );
      _loadCategories();
    } catch (e) {
      _showErrorSnackBar('Gagal menambah kategori: $e');
    }
  }

  Future<void> _updateCategory(Category category, String name, String type) async {
    try {
      final updatedCategory = Category(
        id: category.id,
        userId: category.userId,
        name: name,
        type: type,
        createdAt: category.createdAt,
      );

      await SupabaseService.updateCategory(updatedCategory);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori berhasil diperbarui')),
      );
      _loadCategories();
    } catch (e) {
      _showErrorSnackBar('Gagal memperbarui kategori: $e');
    }
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      await SupabaseService.deleteCategory(category.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori berhasil dihapus')),
      );
      _loadCategories();
    } catch (e) {
      _showErrorSnackBar('Gagal menghapus kategori: $e');
    }
  }
}
