import 'category.dart';

enum TransactionType { income, expense }

class Transaction {
  final int? id;
  final TransactionType type;
  final double amount;
  final int? categoryId;
  final Category? category;
  final String? description;
  final DateTime transactionDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Transaction({
    this.id,
    required this.type,
    required this.amount,
    this.categoryId,
    this.category,
    this.description,
    required this.transactionDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'] == 'income' 
        ? TransactionType.income 
        : TransactionType.expense,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'],
      category: json['category'] != null 
        ? Category.fromJson(json['category']) 
        : null,
      description: json['description'],
      transactionDate: DateTime.parse(json['transaction_date']),
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'category_id': categoryId,
      'description': description,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Transaction copyWith({
    int? id,
    TransactionType? type,
    double? amount,
    int? categoryId,
    Category? category,
    String? description,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
}
