import 'package:cloud_firestore/cloud_firestore.dart';

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
      'date': Timestamp.fromDate(date),
      'isExpense': isExpense,
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];

    DateTime parsedDate;

    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else {
      throw FormatException('Ngày giao dịch không hợp lệ: $rawDate');
    }

    return Transaction(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: parsedDate,
      isExpense: map['isExpense'] as bool? ?? true,
      note: map['note'] as String? ?? '',
    );
  }

  @override
  String toString() {
    final type = isExpense ? 'Chi' : 'Thu';
    final d = '${date.day}/${date.month}/${date.year}';

    return '[$id] $d | $type | $title | $category | $amount | $note';
  }
}
