import 'Transaction.dart';
import 'ListTransaction.dart';

class AppData {
  static const String owner = 'Lê Duy Minh';
  static const String currency = 'VNĐ';
  static const double monthlyBudget = 5000000;

  static const List<String> categories = [
    'Ăn uống',
    'Di chuyển',
    'Mua sắm',
    'Học tập',
    'Hóa đơn',
  ];

  static final ListTransaction transactions = ListTransaction()
    ..create(Transaction(
      id: 't001',
      title: 'Lương tháng 9',
      amount: 8000000,
      category: 'Lương',
      date: DateTime(2025, 9, 5),
      isExpense: false,
    ))
    ..create(Transaction(
      id: 't002',
      title: 'Chi tiêu ăn uống hàng ngày',
      amount: 450000,
      category: 'Ăn uống',
      date: DateTime(2025, 9, 8),
    ))
    ..create(Transaction(
      id: 't003',
      title: 'Thanh toán hóa đơn di động',
      amount: 120000,
      category: 'Hóa đơn',
      date: DateTime(2025, 9, 9),
    ))
    ..create(Transaction(
      id: 't004',
      title: 'Mua tài liệu & học phí Flutter',
      amount: 1500000,
      category: 'Học tập',
      date: DateTime(2025, 9, 10),
    ))
    ..create(Transaction(
      id: 't005',
      title: 'Chi phí xăng xe & di chuyển',
      amount: 300000,
      category: 'Di chuyển',
      date: DateTime(2025, 9, 10),
    ));

  static double get totalExpense {
    double sum = 0;
    for (var t in transactions.items) {
      if (t.isExpense) sum += t.amount;
    }
    return sum;
  }

  static double get totalIncome {
    double sum = 0;
    for (var t in transactions.items) {
      if (!t.isExpense) sum += t.amount;
    }
    return sum;
  }

  static String money(double value) {
    final s = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return '${buffer.toString()} $currency';
  }
}
