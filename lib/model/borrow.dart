class Borrow {
  final int? id;
  final DateTime date;
  final double amount;
  final String person;

  Borrow({
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

  factory Borrow.fromMap(Map<String, dynamic> map) {
    return Borrow(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      person: map['person'],
    );
  }
}
