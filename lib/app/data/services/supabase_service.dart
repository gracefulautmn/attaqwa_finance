import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<void> checkConnection() async {
    await _client.from('accounts').select('id').limit(1);
  }

  Future<void> signInWithEmail(String email, String password) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    if (res.session == null) {
      throw Exception('Gagal login');
    }
  }

  Future<List<Map<String, dynamic>>> getAccountsRaw() async {
    final data = await _client.from('accounts').select('*').order('account_code', ascending: true);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getCategoriesRaw() async {
    final data = await _client.from('categories').select('*').eq('is_active', true).order('category_type', ascending: true);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> insertAccount(Map<String, dynamic> values) async {
    await _client.from('accounts').insert(values);
  }

  Future<void> updateAccount(String id, Map<String, dynamic> values) async {
    await _client.from('accounts').update(values).eq('id', id);
  }

  Future<void> deleteAccount(String id) async {
    await _client.from('accounts').delete().eq('id', id);
  }

  Future<void> createSimpleDoubleEntry({
    required DateTime date,
    required String description,
    required String debitAccountId,
    required String creditAccountId,
    required double amount,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Belum login');

    final inserted = await _client.from('transactions').insert({
      'transaction_date': date.toUtc().toIso8601String(),
      'description': description,
      'created_by': userId,
    }).select('id').single();

    final txId = inserted['id'] as String;

    await _client.from('journal_entries').insert([
      {
        'transaction_id': txId,
        'account_id': debitAccountId,
        'debit': amount,
        'credit': 0,
      },
      {
        'transaction_id': txId,
        'account_id': creditAccountId,
        'debit': 0,
        'credit': amount,
      }
    ]);
  }

  Future<List<Map<String, dynamic>>> fetchGeneralJournal({
    required DateTime start,
    required DateTime end,
  }) async {
    final data = await _client
        .from('journal_entries')
        .select('id, transaction_id, account_id, debit, credit, transactions(transaction_date, description), accounts(account_code, account_name)')
        .gte('transactions.transaction_date', start.toUtc().toIso8601String())
        .lte('transactions.transaction_date', end.toUtc().toIso8601String())
        .order('transactions.transaction_date');
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getGeneralLedger({
    required String accountId,
    required DateTime start,
    required DateTime end,
  }) async {
    final res = await _client.rpc('get_general_ledger', params: {
      'account_id_param': accountId,
      'start_date_param': start.toIso8601String().substring(0, 10),
      'end_date_param': end.toIso8601String().substring(0, 10),
    });
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getActivityStatement({
    required DateTime start,
    required DateTime end,
  }) async {
    final rows = await _client.rpc('get_activity_statement_data', params: {
      'start_date_param': start.toIso8601String().substring(0, 10),
      'end_date_param': end.toIso8601String().substring(0, 10),
    });
    if (rows is List && rows.isNotEmpty) return rows.first as Map<String, dynamic>;
    return {'total_income': 0, 'total_expense': 0, 'surplus_deficit': 0};
  }

  Future<List<Map<String, dynamic>>> getTransactionsRaw() async {
    final data = await _client
        .from('transactions')
        .select('''
          id,
          transaction_date,
          description,
          created_at,
          journal_entries!inner(
            id,
            account_id,
            debit,
            credit,
            accounts(
              id,
              account_code,
              account_name,
              account_type,
              normal_balance
            )
          )
        ''')
        .order('transaction_date', ascending: false);
    
    final List<Map<String, dynamic>> processedTransactions = [];
    
    for (final transaction in (data as List).cast<Map<String, dynamic>>()) {
      final journalEntries = (transaction['journal_entries'] as List).cast<Map<String, dynamic>>();
      
      Map<String, dynamic>? debitEntry;
      Map<String, dynamic>? creditEntry;
      double amount = 0;
      
      for (final entry in journalEntries) {
        if ((entry['debit'] as num) > 0) {
          debitEntry = entry;
          amount = (entry['debit'] as num).toDouble();
        } else if ((entry['credit'] as num) > 0) {
          creditEntry = entry;
        }
      }
      
      processedTransactions.add({
        'id': transaction['id'],
        'transaction_date': transaction['transaction_date'],
        'description': transaction['description'],
        'created_at': transaction['created_at'],
        'amount': amount,
        'debit_account': debitEntry?['accounts'],
        'credit_account': creditEntry?['accounts'],
      });
    }
    
    return processedTransactions;
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _client.from('journal_entries').delete().eq('transaction_id', transactionId);
    
    await _client.from('transactions').delete().eq('id', transactionId);
  }

  Future<String> createTransactionWithCategory({
    required DateTime date,
    required String description,
    required String categoryId,
    required double amount,
  }) async {
    try {
      final result = await _client.rpc('create_simple_transaction', params: {
        'p_date': date.toIso8601String(),
        'p_time': '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00',
        'p_description': description,
        'p_category_id': categoryId,
        'p_amount': amount,
      });
      
      return result.toString();
    } catch (e) {
      throw Exception('Gagal membuat transaksi: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryTypeFilter,
    String? searchTerm,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final result = await _client.rpc('get_transaction_history', params: {
        'start_date_param': startDate?.toIso8601String().split('T')[0],
        'end_date_param': endDate?.toIso8601String().split('T')[0],
        'category_type_filter': categoryTypeFilter,
        'search_term': searchTerm,
        'limit_param': limit,
        'offset_param': offset,
      });
      
      if (result == null) return [];
      if (result is! List) return [];
      
      return result.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error in getTransactionHistory: $e'); 
      throw Exception('Gagal mengambil riwayat transaksi: $e');
    }
  }
}
