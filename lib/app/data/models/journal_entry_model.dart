class JournalEntry {
  final String id;
  final String transactionId;
  final String accountId;
  final double debit;
  final double credit;

  JournalEntry({
    required this.id,
    required this.transactionId,
    required this.accountId,
    required this.debit,
    required this.credit,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> m) => JournalEntry(
        id: m['id'] as String,
        transactionId: m['transaction_id'] as String,
        accountId: m['account_id'] as String,
        debit: double.parse((m['debit'] ?? 0).toString()),
        credit: double.parse((m['credit'] ?? 0).toString()),
      );
}
