import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_data.dart';
import 'transaction.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onSeeAll;
  final ValueChanged<String>? onCategoryTap;

  const HomePage({super.key, this.onSeeAll, this.onCategoryTap});

  static const double cardRadius = 11;
  static const BorderSide cardBorder = BorderSide(
    color: AppTheme.border,
    width: 1.2,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.bold,
    color: AppTheme.textDark,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: ListenableBuilder(
        listenable: AppData.instance,
        builder: (context, _) => _content(),
      ),
    );
  }

  Widget _content() {
    final data = AppData.instance;
    final now = DateTime.now();
    final recent = data.recent();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      children: [
        _greeting(data.owner),
        const SizedBox(height: 12),
        _balanceCard(data, now),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ngân sách tháng ${now.month}/${now.year}',
              style: sectionTitle,
            ),
            Text(
              'Còn ${_daysLeft(now)} ngày',
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _budgetCard(data, now),
        const SizedBox(height: 14),
        const Text('Danh mục', style: sectionTitle),
        const SizedBox(height: 8),
        _categories(),
        const SizedBox(height: 13),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Giao dịch gần đây', style: sectionTitle),
            GestureDetector(
              onTap: onSeeAll,
              child: const Row(
                children: [
                  Text(
                    'Xem tất cả',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward, size: 14, color: AppTheme.textGrey),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Chưa có giao dịch nào',
                style: TextStyle(color: AppTheme.textGrey),
              ),
            ),
          ),
        for (final t in recent) ...[
          _TransactionCard(t),
          const SizedBox(height: 5),
        ],
      ],
    );
  }

  static int _daysLeft(DateTime now) {
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    return lastDay - now.day;
  }

  Widget _greeting(String owner) {
    final name = owner.trim();
    final initial = name.isEmpty ? '?' : name.split(RegExp(r'\s+')).last[0];

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.primaryLight,
          foregroundColor: AppTheme.primary,
          child: Text(
            initial.toUpperCase(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Xin chào,',
                style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
              ),
              const SizedBox(height: 2),
              Text(
                owner,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _balanceCard(AppData data, DateTime now) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Số dư hiện tại',
            style: TextStyle(fontSize: 12, color: AppTheme.primaryLight),
          ),
          const SizedBox(height: 4),
          Text(
            AppData.money(data.balance),
            style: const TextStyle(
              fontSize: 24,
              height: 28 / 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _Summary(
                  icon: Icons.arrow_drop_up,
                  label: 'Thu',
                  value: AppData.number(data.incomeOf(now)),
                  color: AppTheme.income,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _Summary(
                  icon: Icons.arrow_drop_down,
                  label: 'Chi',
                  value: AppData.number(data.expenseOf(now)),
                  color: AppTheme.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _budgetCard(AppData data, DateTime now) {
    final spent = data.expenseOf(now);
    final budget = data.monthlyBudget;
    final ratio = data.budgetRatio(now);
    final status = data.budgetStatus(now);

    final (
      Color textColor,
      Color barColor,
      Color alertBg,
      String? alert,
    ) = switch (status) {
      BudgetStatus.over => (
        AppTheme.expense,
        AppTheme.expense,
        AppTheme.expenseLight,
        'Đã vượt ngân sách ${AppData.money(spent - budget)}',
      ),
      BudgetStatus.warning => (
        AppTheme.warning,
        AppTheme.warningBar,
        AppTheme.warningLight,
        'Sắp chạm ngân sách, còn ${AppData.money(budget - spent)}',
      ),
      BudgetStatus.normal => (
        AppTheme.primary,
        AppTheme.primary,
        Colors.transparent,
        null,
      ),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: const Border.fromBorderSide(cardBorder),
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${AppData.money(spent)} / ${AppData.money(budget)}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                ),
              ),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppTheme.primaryLight,
              color: barColor,
            ),
          ),
          if (alert != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: alertBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: textColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      alert,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _categories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AppData.expenseCategories.map((c) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: AppTheme.card,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppTheme.primary, width: 1.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onCategoryTap == null ? null : () => onCategoryTap!(c),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Text(
                    c,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Summary({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HomePage.cardRadius),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          Text(
            '$label ',
            style: const TextStyle(fontSize: 11, color: AppTheme.textGrey),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction t;

  const _TransactionCard(this.t);

  @override
  Widget build(BuildContext context) {
    final color = t.isExpense ? AppTheme.expense : AppTheme.income;

    return Container(
      height: 61,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: const Border.fromBorderSide(HomePage.cardBorder),
        borderRadius: BorderRadius.circular(HomePage.cardRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.5,
            backgroundColor: t.isExpense
                ? AppTheme.expenseLight
                : AppTheme.primaryLight,
            child: Icon(
              t.isExpense ? Icons.remove : Icons.add,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${t.category} · ${t.date.day}/${t.date.month}/${t.date.year}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${t.isExpense ? '-' : '+'}${AppData.number(t.amount)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
