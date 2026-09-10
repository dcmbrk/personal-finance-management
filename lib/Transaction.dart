class Transaction {
  static int count = 0;

  String id;
  String title;
  double amount;
  String category;
  DateTime date;
  bool isExpense;
  String note;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.isExpense = true,
    this.note = '',
  }) {
    count++;
  }

  double get signedAmount => isExpense ? -amount : amount;

  void update({
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isExpense,
    String? note,
  }) {
    this.title = title ?? this.title;
    this.amount = amount ?? this.amount;
    this.category = category ?? this.category;
    this.date = date ?? this.date;
    this.isExpense = isExpense ?? this.isExpense;
    this.note = note ?? this.note;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isExpense': isExpense,
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      isExpense: map['isExpense'] ?? true,
      note: map['note'] ?? '',
    );
  }

  @override
  String toString() {
    final type = isExpense ? 'Chi' : 'Thu';
    final d = '${date.day}/${date.month}/${date.year}';
    return '[$id] $d | $type | $title | $category | $amount | $note';
  }
}
