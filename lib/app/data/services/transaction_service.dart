import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';

class TransactionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Transaction>> getAllTransactions({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    try {
      var query = _supabase
          .from('transactions')
          .select('''
            *,
            categories!inner(*)
          ''');

      if (startDate != null) {
        query = query.gte('transaction_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('transaction_date', endDate.toIso8601String().split('T')[0]);
      }

      if (type != null) {
        query = query.eq('type', type == TransactionType.income ? 'income' : 'expense');
      }

      final response = await query
          .order('transaction_date', ascending: false)
          .limit(limit ?? 50);

      return (response as List)
          .map((json) {
            if (json['categories'] != null) {
              json['category'] = json['categories'];
            }
            return Transaction.fromJson(json);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await _supabase
          .from('transactions')
          .insert(transaction.toJson())
          .select('''
            *,
            categories!inner(*)
          ''')
          .single();

      if (response['categories'] != null) {
        response['category'] = response['categories'];
      }
      return Transaction.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  Future<Transaction> updateTransaction(Transaction transaction) async {
    try {
      final response = await _supabase
          .from('transactions')
          .update({
            'type': transaction.type == TransactionType.income ? 'income' : 'expense',
            'amount': transaction.amount,
            'category_id': transaction.categoryId,
            'description': transaction.description,
            'transaction_date': transaction.transactionDate.toIso8601String().split('T')[0],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', transaction.id!)
          .select('''
            *,
            categories!inner(*)
          ''')
          .single();

      if (response['categories'] != null) {
        response['category'] = response['categories'];
      }
      return Transaction.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _supabase
          .from('transactions')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  Future<Map<String, double>> getSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('transactions')
          .select('type, amount');

      if (startDate != null) {
        query = query.gte('transaction_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('transaction_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query;

      double totalIncome = 0;
      double totalExpense = 0;

      for (var item in response) {
        double amount = (item['amount'] as num).toDouble();
        if (item['type'] == 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
        }
      }

      return {
        'income': totalIncome,
        'expense': totalExpense,
        'balance': totalIncome - totalExpense,
      };
    } catch (e) {
      throw Exception('Failed to get summary: $e');
    }
  }
}
