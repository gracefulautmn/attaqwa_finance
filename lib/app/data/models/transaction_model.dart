class FinanceTransaction {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String? categoryName;
  final String? categoryType;
  final String createdBy;

  FinanceTransaction({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.createdBy,
    this.categoryName,
    this.categoryType,
  });

  factory FinanceTransaction.fromMap(Map<String, dynamic> m) => FinanceTransaction(
        id: m['id'] as String,
        date: DateTime.parse(m['transaction_date'] as String),
        description: m['description'] as String,
        amount: (m['amount'] as num?)?.toDouble() ?? 0.0,
        createdBy: m['created_by'] as String,
        categoryName: m['category_name'] as String?,
        categoryType: m['category_type'] as String?,
      );
}
