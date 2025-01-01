class Expense {
  final int? id;
  final DateTime date;
  final double amount;
  final String reason;

  Expense({
    this.id,
    required this.date,
    required this.amount,
    required this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'reason': reason,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      reason: map['reason'],
    );
  }
}
