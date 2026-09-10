import 'package:flutter/material.dart';
import 'AppTheme.dart';
import 'AppData.dart';
import 'Transaction.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  String filter = 'Tất cả';

  List<Transaction> get data {
    final items = AppData.transactions.items;
    if (filter == 'Tất cả') return items;
    return items.where((t) => t.category == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['Tất cả', ...AppData.categories];

    return Scaffold(
      appBar: AppBar(title: const Text('Giao dịch')),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.padding),
              child: Row(
                children: filters.map((f) {
                  final selected = f == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: selected,
                      selectedColor: AppTheme.primary,
                      backgroundColor: AppTheme.primaryLight,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) => setState(() => filter = f),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: data.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có giao dịch nào',
                      style: TextStyle(color: AppTheme.textGrey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.padding),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final t = data[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: t.isExpense
                                ? const Color(0xFFFDECEA)
                                : AppTheme.primaryLight,
                            child: Icon(
                              t.isExpense ? Icons.remove : Icons.add,
                              color: t.isExpense ? AppTheme.expense : AppTheme.income,
                            ),
                          ),
                          title: Text(t.title),
                          subtitle: Text(
                            '${t.category} · ${t.date.day}/${t.date.month}/${t.date.year}',
                          ),
                          trailing: Text(
                            '${t.isExpense ? '-' : '+'}${AppData.money(t.amount)}',
                            style: TextStyle(
                              color: t.isExpense ? AppTheme.expense : AppTheme.income,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
