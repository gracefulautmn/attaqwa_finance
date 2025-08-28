import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:attaqwa_finance/models/category.dart';
import 'package:attaqwa_finance/models/transaction.dart';
import 'package:attaqwa_finance/models/financial_summary.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Auth Methods
  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;

  // Category Methods
  static Future<List<Category>> getCategories(String type) async {
    final response = await _client
        .from('categories')
        .select()
        .eq('type', type)
        .order('name', ascending: true);

    return (response as List)
        .map((json) => Category.fromJson(json))
        .toList();
  }

  static Future<Category> createCategory(Category category) async {
    final response = await _client
        .from('categories')
        .insert(category.toInsertJson())
        .select()
        .single();

    return Category.fromJson(response);
  }

  static Future<Category> updateCategory(Category category) async {
    final response = await _client
        .from('categories')
        .update({
          'name': category.name,
          'type': category.type,
        })
        .eq('id', category.id!)
        .select()
        .single();

    return Category.fromJson(response);
  }

  static Future<void> deleteCategory(int categoryId) async {
    await _client.from('categories').delete().eq('id', categoryId);
  }

  // Transaction Methods
  static Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    var query = _client
        .from('transactions')
        .select('''
          *,
          categories!inner(name)
        ''');

    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      query = query.lte('date', endDate.toIso8601String().split('T')[0]);
    }

    var finalQuery = query.order('date', ascending: false);

    if (limit != null) {
      finalQuery = finalQuery.limit(limit);
    }

    final response = await finalQuery;

    return (response as List).map((json) {
      return Transaction.fromJson({
        ...json,
        'category_name': json['categories']?['name'],
      });
    }).toList();
  }

  static Future<Transaction> createTransaction(Transaction transaction) async {
    final response = await _client
        .from('transactions')
        .insert(transaction.toInsertJson())
        .select('''
          *,
          categories!inner(name)
        ''')
        .single();

    return Transaction.fromJson({
      ...response,
      'category_name': response['categories']?['name'],
    });
  }

  static Future<Transaction> updateTransaction(Transaction transaction) async {
    final response = await _client
        .from('transactions')
        .update({
          'category_id': transaction.categoryId,
          'date': transaction.date.toIso8601String().split('T')[0],
          'description': transaction.description,
          'amount': transaction.amount,
          'type': transaction.type,
        })
        .eq('id', transaction.id!)
        .select('''
          *,
          categories!inner(name)
        ''')
        .single();

    return Transaction.fromJson({
      ...response,
      'category_name': response['categories']?['name'],
    });
  }

  static Future<void> deleteTransaction(int transactionId) async {
    await _client.from('transactions').delete().eq('id', transactionId);
  }

  // Financial Summary
  static Future<FinancialSummary> getFinancialSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = currentUser!.id;
    
    var query = _client.rpc('get_financial_summary', params: {
      'user_uuid': userId,
    });

    // If date range is specified, we need to calculate manually
    if (startDate != null || endDate != null) {
      var transactionQuery = _client
          .from('transactions')
          .select('amount, type');

      if (startDate != null) {
        transactionQuery = transactionQuery.gte('date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        transactionQuery = transactionQuery.lte('date', endDate.toIso8601String().split('T')[0]);
      }

      final transactions = await transactionQuery;
      
      double totalPemasukan = 0;
      double totalPengeluaran = 0;

      for (final transaction in transactions) {
        final amount = (transaction['amount'] as num).toDouble();
        if (transaction['type'] == 'Pemasukan') {
          totalPemasukan += amount;
        } else {
          totalPengeluaran += amount;
        }
      }

      return FinancialSummary(
        totalPemasukan: totalPemasukan,
        totalPengeluaran: totalPengeluaran,
        saldoAkhir: totalPemasukan - totalPengeluaran,
      );
    }

    final response = await query.single();
    return FinancialSummary.fromJson(response);
  }
}
