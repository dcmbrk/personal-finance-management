import 'Transaction.dart';

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
      print(t);
    }
  }

  Transaction? findById(String id) {
    for (var t in items) {
      if (t.id == id) return t;
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

void main() {
  var list = ListTransaction();

  list.create(Transaction(
    id: 't001',
    title: 'An trua',
    amount: 45000,
    category: 'An uong',
    date: DateTime(2025, 9, 10),
  ));
  list.create(Transaction(
    id: 't002',
    title: 'Luong thang 9',
    amount: 8000000,
    category: 'Luong',
    date: DateTime(2025, 9, 5),
    isExpense: false,
  ));
  list.create(Transaction(
    id: 't003',
    title: 'Do xang',
    amount: 60000,
    category: 'Di chuyen',
    date: DateTime(2025, 9, 8),
  ));

  list.read();

  list.edit('t003', amount: 80000, note: 'Do day binh');
  print(list.findById('t003'));

  list.read();
  print('So du: ${list.balance}');
  print('Tong so ban ghi da tao: ${Transaction.count}');
}
