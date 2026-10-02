import 'package:flutter/material.dart';
import 'AppTheme.dart';
import 'AppData.dart';
import 'Transaction.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const HomePage({super.key, this.onSeeAll});

  static const double cardRadius = 11;
  static const BorderSide cardBorder = BorderSide(color: AppTheme.border, width: 1.2);

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.bold,
    color: AppTheme.textDark,
  );

  @override
  Widget build(BuildContext context) {
    final spent = AppData.totalExpense;
    final percent = (spent / AppData.monthlyBudget).clamp(0.0, 1.0);
    final recent = AppData.transactions.items.reversed.take(4).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        children: [
          _balanceCard(),
          const SizedBox(height: 12),
          const Text('Ngân sách tháng', style: sectionTitle),
          const SizedBox(height: 8),
          _budgetCard(spent, percent),
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
          for (final t in recent) ...[
            _TransactionCard(t),
            const SizedBox(height: 5),
          ],
        ],
      ),
    );
  }

  Widget _balanceCard() {
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
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            AppData.money(AppData.transactions.balance),
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
                  value: AppData.number(AppData.totalIncome),
                  color: AppTheme.income,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _Summary(
                  icon: Icons.arrow_drop_down,
                  label: 'Chi',
                  value: AppData.number(AppData.totalExpense),
                  color: AppTheme.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _budgetCard(double spent, double percent) {
    return Container(
      height: 56,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 9),
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: const Border.fromBorderSide(cardBorder),
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppData.money(spent)} / ${AppData.money(AppData.monthlyBudget)}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
              ),
              Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
              ),
            ],
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: AppTheme.primaryLight,
              color: percent > 0.8 ? AppTheme.expense : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AppData.categories.map((c) {
          return Container(
            height: 31,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.card,
              border: Border.all(color: AppTheme.primary, width: 1.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              c,
              style: const TextStyle(fontSize: 12, color: AppTheme.primary),
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
          Text('$label ', style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
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
            backgroundColor: t.isExpense ? const Color(0xFFFDECEA) : AppTheme.primaryLight,
            child: Icon(t.isExpense ? Icons.remove : Icons.add, size: 18, color: color),
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
                  style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                ),
                const SizedBox(height: 3),
                Text(
                  '${t.category} · ${t.date.day}/${t.date.month}/${t.date.year}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textGrey),
                ),
              ],
            ),
          ),
          Text(
            '${t.isExpense ? '-' : '+'}${AppData.number(t.amount)}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
