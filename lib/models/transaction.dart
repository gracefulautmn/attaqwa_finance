class Transaction {
  final int? id;
  final String userId;
  final int? categoryId;
  final DateTime date;
  final String? description;
  final double amount;
  final String type; 
  final DateTime createdAt;

  final String? categoryName;

  Transaction({
    this.id,
    required this.userId,
    this.categoryId,
    required this.date,
    this.description,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.categoryName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      categoryName: json['category_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'date': date.toIso8601String().split('T')[0], 
      'description': description,
      'amount': amount,
      'type': type,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'date': date.toIso8601String().split('T')[0],
      'description': description,
      'amount': amount,
      'type': type,
    };
  }
}
