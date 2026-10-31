import 'package:flutter/foundation.dart';

import 'transaction.dart';

class ListTransaction {
  List<Transaction> items = [];

  void create(Transaction t) {
    items.add(t);
  }

  bool edit(
    String id, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isExpense,
    String? note,
  }) {
    for (var t in items) {
      if (t.id == id) {
        t.update(
          title: title,
          amount: amount,
          category: category,
          date: date,
          isExpense: isExpense,
          note: note,
        );

        return true;
      }
    }

    return false;
  }

  void read() {
    for (var t in items) {
      debugPrint('$t');
    }
  }

  Transaction? findById(String id) {
    for (var t in items) {
      if (t.id == id) {
        return t;
      }
    }

    return null;
  }

  bool delete(String id) {
    final before = items.length;

    items.removeWhere((t) => t.id == id);

    return items.length < before;
  }

  double get balance {
    double sum = 0;

    for (var t in items) {
      sum += t.signedAmount;
    }

    return sum;
  }
}
