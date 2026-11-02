import 'package:flutter/foundation.dart';

import 'transaction.dart';
import 'list_transaction.dart';
import 'services/transaction_repository.dart';

class AppData extends ChangeNotifier {
  AppData._();

  static final AppData instance = AppData._();

  static const String currency = 'VNĐ';
  static const String defaultOwner = 'Lê Duy Tùng';
  static const double defaultBudget = 5000000;
  static const double warningRatio = 0.8;
  static const String allCategories = 'Tất cả';

  static const List<String> expenseCategories = [
    'Ăn uống',
    'Di chuyển',
    'Mua sắm',
    'Học tập',
    'Hóa đơn',
    'Khác',
  ];

  static const List<String> incomeCategories = [
    'Lương',
    'Thưởng',
    'Làm thêm',
    'Khác',
  ];

  static const List<String> categories = expenseCategories;

  final ListTransaction _list = ListTransaction();

  String _owner = defaultOwner;
  double _budget = defaultBudget;

  final ValueNotifier<String> categoryFilter = ValueNotifier(allCategories);

  static ListTransaction get transactions => instance._list;

  List<Transaction> get items => List.unmodifiable(_list.items);

  String get owner => _owner;

  double get monthlyBudget => _budget;

  // Tải hồ sơ và giao dịch từ Firestore.
  Future<void> load() async {
    final repository = TransactionRepository.instance;

    final userData = await repository.loadUserData();

    _owner = userData['owner'] as String? ?? defaultOwner;

    _budget = (userData['monthlyBudget'] as num?)?.toDouble() ?? defaultBudget;

    final isNewUser = userData['_isNewUser'] == true;

    List<Transaction> loadedTransactions = await repository.loadTransactions();

    // Chỉ tạo dữ liệu mẫu khi tài khoản chưa có hồ sơ.
    if (isNewUser) {
      loadedTransactions = sampleTransactions();

      await repository.replaceTransactions(loadedTransactions);
    }

    _list.items = loadedTransactions;

    notifyListeners();
  }

  void _changed() {
    notifyListeners();
  }

  // Tạo ID giao dịch theo thứ tự: t001, t002, t003...
  // Dựa trên các ID hiện có để tránh trùng với dữ liệu đã tải.
  String newId() {
    int maxId = 0;

    for (final transaction in _list.items) {
      final match = RegExp(r'^t(\d+)$').firstMatch(transaction.id);

      if (match != null) {
        final number = int.tryParse(match.group(1) ?? '');

        if (number != null && number > maxId) {
          maxId = number;
        }
      }
    }

    final nextId = maxId + 1;

    return 't${nextId.toString().padLeft(3, '0')}';
  }

  // Thêm giao dịch.
  Future<void> add(Transaction t) async {
    await TransactionRepository.instance.addTransaction(t);

    _list.create(t);

    _changed();
  }

  // Cập nhật giao dịch.
  Future<bool> update(
    String id, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isExpense,
    String? note,
  }) async {
    final current = _list.findById(id);

    if (current == null) return false;

    final updatedTransaction = Transaction(
      id: current.id,
      title: title ?? current.title,
      amount: amount ?? current.amount,
      category: category ?? current.category,
      date: date ?? current.date,
      isExpense: isExpense ?? current.isExpense,
      note: note ?? current.note,
    );

    await TransactionRepository.instance.updateTransaction(updatedTransaction);

    final ok = _list.edit(
      id,
      title: title,
      amount: amount,
      category: category,
      date: date,
      isExpense: isExpense,
      note: note,
    );

    if (ok) {
      _changed();
    }

    return ok;
  }

  // Xóa giao dịch.
  Future<bool> remove(String id) async {
    final current = _list.findById(id);

    if (current == null) return false;

    await TransactionRepository.instance.deleteTransaction(id);

    final ok = _list.delete(id);

    if (ok) {
      _changed();
    }

    return ok;
  }

  Transaction? findById(String id) => _list.findById(id);

  List<Transaction> recent([int count = 4]) {
    final sorted = [..._list.items]..sort((a, b) => b.date.compareTo(a.date));

    return sorted.take(count).toList();
  }

  static bool sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  List<Transaction> inMonth(DateTime month) =>
      _list.items.where((t) => sameMonth(t.date, month)).toList();

  double incomeOf(DateTime month) {
    double sum = 0;

    for (var t in inMonth(month)) {
      if (!t.isExpense) sum += t.amount;
    }

    return sum;
  }

  double expenseOf(DateTime month) {
    double sum = 0;

    for (var t in inMonth(month)) {
      if (t.isExpense) sum += t.amount;
    }

    return sum;
  }

  Map<String, double> expenseByCategory(DateTime month) {
    final result = <String, double>{};

    for (var t in inMonth(month)) {
      if (t.isExpense) {
        result[t.category] = (result[t.category] ?? 0) + t.amount;
      }
    }

    return result;
  }

  double get balance => _list.balance;

  double budgetRatio(DateTime month) =>
      _budget <= 0 ? 0 : expenseOf(month) / _budget;

  BudgetStatus budgetStatus(DateTime month) {
    final ratio = budgetRatio(month);

    if (ratio > 1) return BudgetStatus.over;
    if (ratio >= warningRatio) return BudgetStatus.warning;

    return BudgetStatus.normal;
  }

  // Cập nhật tên người dùng.
  Future<void> setOwner(String name) async {
    final value = name.trim();

    if (value.isEmpty) return;

    await TransactionRepository.instance.updateUserData(owner: value);

    _owner = value;

    _changed();
  }

  // Cập nhật ngân sách.
  Future<void> setBudget(double value) async {
    if (value <= 0) return;

    await TransactionRepository.instance.updateUserData(monthlyBudget: value);

    _budget = value;

    _changed();
  }

  // Khôi phục dữ liệu mẫu.
  Future<void> resetSampleData() async {
    final sampleData = sampleTransactions();

    await TransactionRepository.instance.replaceTransactions(sampleData);

    await TransactionRepository.instance.updateUserData(
      owner: defaultOwner,
      monthlyBudget: defaultBudget,
    );

    _list.items = sampleData;
    _owner = defaultOwner;
    _budget = defaultBudget;

    _changed();
  }

  // Xóa toàn bộ giao dịch.
  Future<void> clearAll() async {
    await TransactionRepository.instance.clearTransactions();

    _list.items = [];

    _changed();
  }

  // Năm giao dịch mẫu ban đầu.
  static List<Transaction> sampleTransactions([DateTime? now]) {
    final n = now ?? DateTime.now();

    DateTime day(int d) => DateTime(n.year, n.month, d > n.day ? n.day : d);

    return [
      Transaction(
        id: 't001',
        title: 'Lương tháng ${n.month}',
        amount: 8000000,
        category: 'Lương',
        date: day(1),
        isExpense: false,
      ),
      Transaction(
        id: 't002',
        title: 'Chi tiêu ăn uống hàng ngày',
        amount: 450000,
        category: 'Ăn uống',
        date: day(2),
      ),
      Transaction(
        id: 't003',
        title: 'Thanh toán hóa đơn di động',
        amount: 120000,
        category: 'Hóa đơn',
        date: day(3),
      ),
      Transaction(
        id: 't004',
        title: 'Mua tài liệu & học phí Flutter',
        amount: 1500000,
        category: 'Học tập',
        date: day(4),
      ),
      Transaction(
        id: 't005',
        title: 'Chi phí xăng xe & di chuyển',
        amount: 300000,
        category: 'Di chuyển',
        date: day(5),
      ),
    ];
  }

  static String number(double value) {
    final negative = value < 0;
    final s = value.abs().toStringAsFixed(0);
    final buffer = StringBuffer();

    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(s[i]);
    }

    return negative ? '-$buffer' : buffer.toString();
  }

  static String money(double value) => '${number(value)} $currency';

  static double? parseMoney(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) return null;

    return double.tryParse(digits);
  }
}

enum BudgetStatus { normal, warning, over }
