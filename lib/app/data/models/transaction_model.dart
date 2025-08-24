class FinanceTransaction {
  final String id;
  final DateTime date;
  final String description;
  final String? proofImagePath;
  final String createdBy;

  FinanceTransaction({
    required this.id,
    required this.date,
    required this.description,
    required this.createdBy,
    this.proofImagePath,
  });

  factory FinanceTransaction.fromMap(Map<String, dynamic> m) => FinanceTransaction(
        id: m['id'] as String,
        date: DateTime.parse(m['transaction_date'] as String),
        description: m['description'] as String,
        createdBy: m['created_by'] as String,
        proofImagePath: m['proof_image_path'] as String?,
      );
}
