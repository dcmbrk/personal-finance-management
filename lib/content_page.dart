import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_data.dart';
import 'transaction.dart';
import 'add_transaction_page.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';
  String _typeFilter = 'Tất cả';

  String get categoryFilter => AppData.instance.categoryFilter.value;

  final DateTime _selectedMonth = DateTime.now();

  List<String> get categoryFilters => [
    AppData.allCategories,
    ...AppData.expenseCategories,
    ...AppData.incomeCategories,
  ];

  List<Transaction> get filteredTransactions {
    final items = AppData.instance.items;

    final result = items.where((transaction) {
      final matchesSearch = transaction.title.toLowerCase().contains(
        _searchText.toLowerCase(),
      );

      final matchesType =
          _typeFilter == 'Tất cả' ||
          (_typeFilter == 'Thu' && !transaction.isExpense) ||
          (_typeFilter == 'Chi' && transaction.isExpense);

      final matchesCategory =
          categoryFilter == AppData.allCategories ||
          transaction.category == categoryFilter;

      return matchesSearch && matchesType && matchesCategory;
    }).toList();

    result.sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);

      if (dateCompare != 0) {
        return dateCompare;
      }

      return b.id.compareTo(a.id);
    });

    return result;
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String weekdayName(DateTime date) {
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];

    return weekdays[date.weekday - 1];
  }

  String get monthTitle =>
      'Tháng ${_selectedMonth.month}/${_selectedMonth.year}';

  double get monthlyIncome => AppData.instance.incomeOf(_selectedMonth);

  double get monthlyExpense => AppData.instance.expenseOf(_selectedMonth);

  int get monthlyTransactionCount =>
      AppData.instance.inMonth(_selectedMonth).length;

  Future<void> _addTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionPage()),
    );
  }

  Future<void> _editTransaction(Transaction transaction) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(transaction: transaction),
      ),
    );
  }

  Future<bool> _confirmDelete(Transaction transaction) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa giao dịch'),
          content: Text(
            'Bạn có chắc chắn muốn xóa '
            '"${transaction.title}" không?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (result != true || !mounted) {
      return false;
    }

    try {
      final removed = await AppData.instance.remove(transaction.id);

      if (!removed) {
        throw Exception('Không tìm thấy giao dịch cần xóa.');
      }

      if (!mounted) return true;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xóa giao dịch'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () {
              _restoreTransaction(transaction);
            },
          ),
        ),
      );

      return true;
    } catch (error) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể xóa giao dịch. Vui lòng thử lại.\n$error'),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    }
  }

  Future<void> _restoreTransaction(Transaction transaction) async {
    try {
      await AppData.instance.add(transaction);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã khôi phục giao dịch')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể khôi phục giao dịch. Vui lòng thử lại.\n$error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMonthlySummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$monthTitle · $monthlyTransactionCount giao dịch',
            style: const TextStyle(fontSize: 14, color: AppTheme.textGrey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Tổng thu',
                  monthlyIncome,
                  AppTheme.income,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  'Tổng chi',
                  monthlyExpense,
                  AppTheme.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            AppData.money(amount),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Tìm theo tiêu đề...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textGrey),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchText = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F6F7),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFDADDE0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFDADDE0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    const types = ['Tất cả', 'Thu', 'Chi'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: types.map((type) {
          final selected = _typeFilter == type;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _typeFilter = type;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 54,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoryFilters.length,
        itemBuilder: (context, index) {
          final category = categoryFilters[index];

          final selected = category == categoryFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              selectedColor: AppTheme.primary,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? AppTheme.primary : const Color(0xFFDADDE0),
              ),
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppTheme.primary,
                fontWeight: FontWeight.w500,
              ),
              onSelected: (_) {
                AppData.instance.categoryFilter.value = category;
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, List<Transaction> transactions) {
    final total = transactions.fold<double>(
      0,
      (sum, t) => sum + t.signedAmount,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${weekdayName(date)}, ${formatDate(date)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '${total > 0 ? '+' : ''}${AppData.number(total)}',
            style: const TextStyle(fontSize: 14, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isExpense = transaction.isExpense;

    final amountColor = isExpense ? AppTheme.expense : AppTheme.income;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,

      // Chỉ cho phép vuốt xóa khi Firestore xóa thành công.
      confirmDismiss: (_) => _confirmDelete(transaction),

      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 27),
            SizedBox(height: 4),
            Text(
              'Xóa',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _editTransaction(transaction);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isExpense
                      ? const Color(0xFFFDECEA)
                      : AppTheme.primaryLight,
                  child: Icon(
                    isExpense ? Icons.remove : Icons.add,
                    color: amountColor,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        transaction.note.isEmpty
                            ? transaction.category
                            : '${transaction.category} · ${transaction.note}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${isExpense ? '-' : '+'}${AppData.number(transaction.amount)}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    final items = filteredTransactions;

    if (items.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 65, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Không tìm thấy giao dịch nào',
                style: TextStyle(fontSize: 16, color: AppTheme.textGrey),
              ),
            ],
          ),
        ),
      );
    }

    final grouped = <DateTime, List<Transaction>>{};

    for (final transaction in items) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(transaction);
    }

    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final transactions = grouped[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(date, transactions),
              ...transactions.map(
                (transaction) => _buildTransactionCard(transaction),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giao dịch'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 32),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          AppData.instance,
          AppData.instance.categoryFilter,
        ]),
        builder: (context, _) {
          return Column(
            children: [
              _buildSearchField(),
              _buildTypeFilter(),
              _buildCategoryFilter(),
              const Divider(height: 1, color: Color(0xFFE5E5E5)),
              _buildMonthlySummary(),
              _buildTransactionList(),
            ],
          );
        },
      ),
    );
  }
}
