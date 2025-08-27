class Account {
  final String id;
  final String code;
  final String name;
  final String type;         
  final String normalBalance; 

  Account({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.normalBalance,
  });

  factory Account.fromMap(Map<String, dynamic> m) => Account(
        id: m['id'] as String,
        code: m['account_code'] as String,
        name: m['account_name'] as String,
        type: m['account_type'] as String,
        normalBalance: m['normal_balance'] as String,
      );

  Map<String, dynamic> toInsert() => {
        'account_code': code,
        'account_name': name,
        'account_type': type,
        'normal_balance': normalBalance,
      };
}
