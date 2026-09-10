import 'package:flutter/material.dart';
import 'AppTheme.dart';
import 'AppData.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final spent = AppData.totalExpense;
    final percent = (spent / AppData.monthlyBudget).clamp(0.0, 1.0);
    final recent = AppData.transactions.items.reversed.take(4).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Số dư hiện tại',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppData.money(AppData.transactions.balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _Summary(
                          icon: Icons.arrow_downward,
                          label: 'Thu nhập',
                          value: AppData.money(AppData.totalIncome),
                        ),
                      ),
                      Expanded(
                        child: _Summary(
                          icon: Icons.arrow_upward,
                          label: 'Chi tiêu',
                          value: AppData.money(AppData.totalExpense),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Ngân sách tháng 9', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppData.money(spent)),
                        Text(
                          AppData.money(AppData.monthlyBudget),
                          style: const TextStyle(color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 10,
                        backgroundColor: AppTheme.primaryLight,
                        color: percent > 0.8 ? AppTheme.expense : AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đã dùng ${(percent * 100).toStringAsFixed(0)}% ngân sách',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Danh mục', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AppData.categories.map((c) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Text('Giao dịch gần đây', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...recent.map((t) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        t.isExpense ? const Color(0xFFFDECEA) : AppTheme.primaryLight,
                    child: Icon(
                      t.isExpense ? Icons.remove : Icons.add,
                      color: t.isExpense ? AppTheme.expense : AppTheme.income,
                    ),
                  ),
                  title: Text(t.title),
                  subtitle: Text('${t.category} · ${t.date.day}/${t.date.month}/${t.date.year}'),
                  trailing: Text(
                    '${t.isExpense ? '-' : '+'}${AppData.money(t.amount)}',
                    style: TextStyle(
                      color: t.isExpense ? AppTheme.expense : AppTheme.income,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Summary({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white24,
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
