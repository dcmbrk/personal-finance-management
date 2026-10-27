import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'transaction.dart';
import 'list_transaction.dart';

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

  static const String _keyTransactions = 'transactions';
  static const String _keyOwner = 'owner';
  static const String _keyBudget = 'monthlyBudget';

  final ListTransaction _list = ListTransaction();
  String _owner = defaultOwner;
  double _budget = defaultBudget;
  SharedPreferences? _prefs;

  final ValueNotifier<String> categoryFilter = ValueNotifier(allCategories);

  static ListTransaction get transactions => instance._list;

  List<Transaction> get items => List.unmodifiable(_list.items);
  String get owner => _owner;
  double get monthlyBudget => _budget;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final prefs = _prefs!;

    _owner = prefs.getString(_keyOwner) ?? defaultOwner;
    _budget = prefs.getDouble(_keyBudget) ?? defaultBudget;

    final raw = prefs.getString(_keyTransactions);
    _list.items = raw == null ? sampleTransactions() : _decode(raw);
    notifyListeners();
  }

  List<Transaction> _decode(String raw) {
    try {
      final data = jsonDecode(raw) as List;
      return data
          .map((e) => Transaction.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return sampleTransactions();
    }
  }

  void _changed() {
    notifyListeners();
    final prefs = _prefs;
    if (prefs == null) return;
    prefs.setString(
      _keyTransactions,
      jsonEncode(_list.items.map((t) => t.toMap()).toList()),
    );
    prefs.setString(_keyOwner, _owner);
    prefs.setDouble(_keyBudget, _budget);
  }

  String newId() => 't${DateTime.now().microsecondsSinceEpoch}';

  void add(Transaction t) {
    _list.create(t);
    _changed();
  }

  bool update(
    String id, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isExpense,
    String? note,
  }) {
    final ok = _list.edit(
      id,
      title: title,
      amount: amount,
      category: category,
      date: date,
      isExpense: isExpense,
      note: note,
    );
    if (ok) _changed();
    return ok;
  }

  bool remove(String id) {
    final ok = _list.delete(id);
    if (ok) _changed();
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

  void setOwner(String name) {
    final value = name.trim();
    if (value.isEmpty) return;
    _owner = value;
    _changed();
  }

  void setBudget(double value) {
    if (value <= 0) return;
    _budget = value;
    _changed();
  }

  void resetSampleData() {
    _list.items = sampleTransactions();
    _owner = defaultOwner;
    _budget = defaultBudget;
    _changed();
  }

  void clearAll() {
    _list.items = [];
    _changed();
  }

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
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
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
