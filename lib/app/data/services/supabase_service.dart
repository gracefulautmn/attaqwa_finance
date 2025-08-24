import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  // Splash check
  Future<void> checkConnection() async {
    await _client.from('accounts').select('id').limit(1);
  }

  // Auth
  Future<void> signInWithEmail(String email, String password) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    if (res.session == null) {
      throw Exception('Gagal login');
    }
  }

  // Accounts
  Future<List<Map<String, dynamic>>> getAccountsRaw() async {
    final data = await _client.from('accounts').select('*').order('account_code', ascending: true);
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

  // Transaksi sederhana (double-entry 1 lawan 1)
  Future<void> createSimpleDoubleEntry({
    required DateTime date,
    required String description,
    String? proofImagePath,
    required String debitAccountId,
    required String creditAccountId,
    required double amount,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Belum login');

    // Insert transactions & lines dalam 2 langkah aman
    final inserted = await _client.from('transactions').insert({
      'transaction_date': date.toUtc().toIso8601String(),
      'description': description,
      'proof_image_path': proofImagePath,
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

  // General Journal (rentang tanggal) - contoh sederhana
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

  // RPC: Buku Besar
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

  // RPC: Laporan Aktivitas
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
}
