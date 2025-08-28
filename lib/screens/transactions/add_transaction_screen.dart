import 'package:flutter/material.dart';
import 'package:attaqwa_finance/models/category.dart';
import 'package:attaqwa_finance/models/transaction.dart';
import 'package:attaqwa_finance/services/supabase_service.dart';
import 'package:attaqwa_finance/theme/app_theme.dart';
import 'package:attaqwa_finance/utils/currency_utils.dart' as utils;

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'Pemasukan';
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categories = await SupabaseService.getCategories(_selectedType);
      setState(() {
        _categories = categories;
        _selectedCategory = categories.isNotEmpty ? categories.first : null;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      _showErrorSnackBar('Gagal memuat kategori: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showErrorSnackBar('Pilih kategori terlebih dahulu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('User tidak ditemukan');
      }

      final amount = double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
      
      final transaction = Transaction(
        userId: user.id,
        categoryId: _selectedCategory!.id!,
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        amount: amount,
        type: _selectedType,
        createdAt: DateTime.now(),
      );

      await SupabaseService.createTransaction(transaction);
      
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Gagal menyimpan transaksi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTransaction,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Simpan',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Selection
              Text(
                'Jenis Transaksi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_selectedType != 'Pemasukan') {
                            setState(() {
                              _selectedType = 'Pemasukan';
                              _selectedCategory = null;
                            });
                            _loadCategories();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedType == 'Pemasukan'
                                ? AppTheme.accentIncome
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: _selectedType == 'Pemasukan'
                                    ? Colors.white
                                    : AppTheme.accentIncome,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pemasukan',
                                style: TextStyle(
                                  color: _selectedType == 'Pemasukan'
                                      ? Colors.white
                                      : AppTheme.accentIncome,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_selectedType != 'Pengeluaran') {
                            setState(() {
                              _selectedType = 'Pengeluaran';
                              _selectedCategory = null;
                            });
                            _loadCategories();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedType == 'Pengeluaran'
                                ? AppTheme.accentExpense
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.trending_down,
                                color: _selectedType == 'Pengeluaran'
                                    ? Colors.white
                                    : AppTheme.accentExpense,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pengeluaran',
                                style: TextStyle(
                                  color: _selectedType == 'Pengeluaran'
                                      ? Colors.white
                                      : AppTheme.accentExpense,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Category Selection
              Text(
                'Kategori',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : _categories.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Belum ada kategori ${_selectedType.toLowerCase()}',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  // Navigate to add category
                                  Navigator.of(context).pushNamed('/add-category');
                                },
                                child: const Text('Tambah Kategori'),
                              ),
                            ],
                          ),
                        )
                      : DropdownButtonFormField<Category>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (Category? value) {
                            setState(() => _selectedCategory = value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Pilih kategori';
                            }
                            return null;
                          },
                        ),

              const SizedBox(height: 24),

              // Amount Input
              Text(
                'Jumlah',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan jumlah',
                  prefixText: 'Rp ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  final amount = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
                  if (amount == null || amount <= 0) {
                    return 'Masukkan jumlah yang valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Date Selection
              Text(
                'Tanggal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppTheme.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        utils.DateUtils.formatDate(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Description Input
              Text(
                'Deskripsi (Opsional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan deskripsi transaksi',
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTransaction,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan Transaksi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
