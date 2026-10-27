import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:personal_finance/app_data.dart';
import 'package:personal_finance/settings_page.dart';
import 'package:personal_finance/transaction.dart';

void main() {
  final data = AppData.instance;
  final now = DateTime.now();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await data.load();
  });

  group('Tải dữ liệu', () {
    test('lần đầu mở app dùng dữ liệu mẫu', () {
      expect(data.items.length, 5);
      expect(data.owner, AppData.defaultOwner);
      expect(data.monthlyBudget, AppData.defaultBudget);
    });

    test('dữ liệu mẫu nằm trong tháng hiện tại', () {
      expect(data.inMonth(now).length, 5);
      expect(data.incomeOf(now), 8000000);
      expect(data.expenseOf(now), 2370000);
      expect(data.balance, 5630000);
    });

    test('dữ liệu hỏng thì quay về dữ liệu mẫu', () async {
      SharedPreferences.setMockInitialValues({'transactions': 'không phải json'});
      await data.load();
      expect(data.items.length, 5);
    });
  });

  group('Thêm / sửa / xoá', () {
    test('add thêm giao dịch và báo cho UI', () {
      var notified = 0;
      void listener() => notified++;
      data.addListener(listener);

      data.add(Transaction(
        id: data.newId(),
        title: 'Cà phê',
        amount: 30000,
        category: 'Ăn uống',
        date: now,
      ));

      data.removeListener(listener);
      expect(data.items.length, 6);
      expect(data.expenseOf(now), 2400000);
      expect(notified, 1);
    });

    test('update sửa đúng giao dịch', () {
      expect(data.update('t002', amount: 500000, note: 'cơm trưa'), isTrue);
      expect(data.findById('t002')!.amount, 500000);
      expect(data.findById('t002')!.note, 'cơm trưa');
      expect(data.update('khong-co', amount: 1), isFalse);
    });

    test('remove xoá giao dịch', () {
      expect(data.remove('t004'), isTrue);
      expect(data.findById('t004'), isNull);
      expect(data.expenseOf(now), 870000);
      expect(data.remove('t004'), isFalse);
    });

    test('recent trả về giao dịch mới nhất trước', () {
      final recent = data.recent(10);
      for (var i = 1; i < recent.length; i++) {
        expect(recent[i - 1].date.isBefore(recent[i].date), isFalse);
      }
      expect(data.recent(3).length, 3);
    });

    test('giao dịch tháng khác không tính vào tháng này', () {
      data.add(Transaction(
        id: data.newId(),
        title: 'Tháng trước',
        amount: 999000,
        category: 'Mua sắm',
        date: DateTime(now.year, now.month - 1, 15),
      ));
      expect(data.expenseOf(now), 2370000);
    });

    test('expenseByCategory cộng theo danh mục', () {
      final map = data.expenseByCategory(now);
      expect(map['Học tập'], 1500000);
      expect(map['Ăn uống'], 450000);
      expect(map.containsKey('Lương'), isFalse);
    });
  });

  group('Ngân sách', () {
    test('dưới 80% là bình thường', () {
      expect(data.budgetStatus(now), BudgetStatus.normal);
    });

    test('từ 80% là cảnh báo', () {
      data.setBudget(2370000 / 0.8);
      expect(data.budgetStatus(now), BudgetStatus.warning);
    });

    test('vượt 100% là vượt ngân sách', () {
      data.setBudget(2000000);
      expect(data.budgetStatus(now), BudgetStatus.over);
      expect(data.budgetRatio(now), greaterThan(1));
    });

    test('không nhận ngân sách <= 0', () {
      data.setBudget(0);
      expect(data.monthlyBudget, AppData.defaultBudget);
    });
  });

  group('Lưu trữ', () {
    test('dữ liệu còn sau khi mở lại app', () async {
      data.add(Transaction(
        id: 'x1',
        title: 'Làm thêm',
        amount: 1000000,
        category: 'Làm thêm',
        date: now,
        isExpense: false,
      ));
      data.setBudget(7000000);
      data.setOwner('  Minh  ');

      await data.load();

      expect(data.findById('x1')!.title, 'Làm thêm');
      expect(data.monthlyBudget, 7000000);
      expect(data.owner, 'Minh');
    });

    test('clearAll và resetSampleData', () async {
      data.clearAll();
      await data.load();
      expect(data.items, isEmpty);

      data.resetSampleData();
      expect(data.items.length, 5);
    });
  });

  group('Định dạng & nhập liệu', () {
    test('number có dấu chấm và số âm', () {
      expect(AppData.number(5000000), '5.000.000');
      expect(AppData.number(950), '950');
      expect(AppData.number(-1500000), '-1.500.000');
      expect(AppData.money(120000), '120.000 VNĐ');
    });

    test('parseMoney bỏ ký tự không phải số', () {
      expect(AppData.parseMoney('5.000.000'), 5000000);
      expect(AppData.parseMoney('3000000 VNĐ'), 3000000);
      expect(AppData.parseMoney('abc'), isNull);
    });

    test('validateBudget', () {
      expect(SettingsPage.validateBudget(''), isNotNull);
      expect(SettingsPage.validateBudget('0'), isNotNull);
      expect(SettingsPage.validateBudget('9999999999999'), isNotNull);
      expect(SettingsPage.validateBudget('5.000.000'), isNull);
    });

    test('Transaction.fromMap nhận amount kiểu int', () {
      final t = Transaction.fromMap({
        'id': 'a',
        'title': 'b',
        'amount': 100,
        'category': 'Khác',
        'date': '2026-10-01T00:00:00.000',
        'isExpense': true,
      });
      expect(t.amount, 100.0);
    });
  });
}
