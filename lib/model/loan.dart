class Loan {
  final int? id;
  final DateTime date;
  final double amount;
  final String person;

  Loan({
    this.id,
    required this.date,
    required this.amount,
    required this.person,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'person': person,
    };
  }

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      person: map['person'],
    );
  }
}
