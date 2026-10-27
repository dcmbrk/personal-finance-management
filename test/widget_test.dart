import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:personal_finance/app_data.dart';
import 'package:personal_finance/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppData.instance.load();
  });

  testWidgets('Trang chủ hiện lời chào và ngân sách', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Xin chào,'), findsOneWidget);
    expect(find.text(AppData.defaultOwner), findsWidgets);
    expect(find.text('47%'), findsOneWidget);
    expect(find.textContaining('Sắp chạm ngân sách'), findsNothing);
  });

  testWidgets('Trang chủ cảnh báo khi vượt ngân sách', (tester) async {
    AppData.instance.setBudget(2000000);
    await tester.pumpWidget(const MyApp());

    expect(find.textContaining('Đã vượt ngân sách'), findsOneWidget);
  });

  testWidgets('Cài đặt kiểm tra ngân sách và lưu', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    final field = find.byKey(const Key('budgetField'));
    final save = find.text('Lưu ngân sách');

    await tester.enterText(field, '0');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();
    expect(find.text('Ngân sách phải lớn hơn 0'), findsOneWidget);

    await tester.enterText(field, '2000000');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();
    expect(AppData.instance.monthlyBudget, 2000000);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.textContaining('Đã vượt ngân sách'), findsOneWidget);
  });
}
