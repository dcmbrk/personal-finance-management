import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_data.dart';
import 'app_theme.dart';
import 'transaction.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  static const List<Color> chartColors = [
    Color(0xFF2E7D32),
    Color(0xFFFFA000),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFF78909C),
    Color(0xFFBDBDBD),
  ];

  // Chuyển tháng trước
  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  // Chuyển tháng tiếp theo
  void _nextMonth() {
    final now = DateTime.now();

    // Không cho xem tháng trong tương lai
    if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) {
      return;
    }

    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  String get _monthTitle {
    return 'Tháng ${_selectedMonth.month}/${_selectedMonth.year}';
  }

  // Dữ liệu giao dịch trong tháng
  List<Transaction> get _monthTransactions {
    return AppData.instance.inMonth(_selectedMonth);
  }

  // Tổng thu
  double get _totalIncome {
    return AppData.instance.incomeOf(_selectedMonth);
  }

  // Tổng chi
  double get _totalExpense {
    return AppData.instance.expenseOf(_selectedMonth);
  }

  // Chênh lệch thu chi
  double get _difference {
    return _totalIncome - _totalExpense;
  }

  // Danh sách chi tiêu theo danh mục
  Map<String, double> get _categoryExpenses {
    return AppData.instance.expenseByCategory(_selectedMonth);
  }

  // Top 3 khoản chi lớn nhất
  List<Transaction> get _topExpenses {
    final expenses = _monthTransactions.where((t) => t.isExpense).toList();

    expenses.sort((a, b) => b.amount.compareTo(a.amount));

    return expenses.take(3).toList();
  }

  // Dữ liệu thu chi 6 tháng
  List<_MonthlyData> get _sixMonthData {
    final result = <_MonthlyData>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(_selectedMonth.year, _selectedMonth.month - i);

      result.add(
        _MonthlyData(
          month: month,
          income: AppData.instance.incomeOf(month),
          expense: AppData.instance.expenseOf(month),
        ),
      );
    }

    return result;
  }

  // Định dạng số tiền rút gọn
  String _compactMoney(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)} tỷ';
    }

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)} tr';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} k';
    }

    return AppData.number(value);
  }

  // Thẻ tổng quan
  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color, {
    bool highlighted = false,
  }) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: highlighted ? color : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: highlighted ? color : const Color(0xFFDADDE0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: highlighted ? Colors.white70 : AppTheme.textGrey,
              ),
            ),

            const SizedBox(height: 7),

            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${amount >= 0 ? '+' : ''}${AppData.number(amount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: highlighted ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bộ chọn tháng
  Widget _buildMonthSelector() {
    final now = DateTime.now();

    final isCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _monthButton(Icons.chevron_left, _previousMonth),

          Text(
            _monthTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          _monthButton(
            Icons.chevron_right,
            _nextMonth,
            disabled: isCurrentMonth,
          ),
        ],
      ),
    );
  }

  Widget _monthButton(
    IconData icon,
    VoidCallback onPressed, {
    bool disabled = false,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: disabled ? null : onPressed,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDADDE0)),
          ),
          child: Icon(
            icon,
            size: 27,
            color: disabled ? Colors.grey.shade400 : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Khu vực 3 thẻ tổng quan
  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildSummaryCard('Tổng thu', _totalIncome, AppTheme.income),

          const SizedBox(width: 9),

          _buildSummaryCard('Tổng chi', _totalExpense, AppTheme.expense),

          const SizedBox(width: 9),

          _buildSummaryCard(
            'Chênh lệch',
            _difference,
            AppTheme.primary,
            highlighted: true,
          ),
        ],
      ),
    );
  }

  // Khung biểu đồ
  Widget _chartCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDADDE0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }

  // Biểu đồ tròn
  Widget _buildCategoryChart() {
    final entries = _categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return const SizedBox(
        height: 190,
        child: Center(
          child: Text(
            'Chưa có dữ liệu chi tiêu trong tháng này',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
          ),
        ),
      );
    }

    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 5,
              child: SizedBox(
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(180, 180),
                      painter: _DonutChartPainter(
                        values: entries.map((e) => e.value).toList(),
                        colors: List.generate(
                          entries.length,
                          (index) => chartColors[index % chartColors.length],
                        ),
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Tổng chi',
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          _compactMoney(total),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              flex: 5,
              child: Column(
                children: List.generate(entries.length, (index) {
                  final entry = entries[index];

                  final percentage = entry.value / total * 100;

                  final color = chartColors[index % chartColors.length];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),

                        const SizedBox(width: 7),

                        Expanded(
                          child: Text(
                            entry.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),

                        Text(
                          '${percentage.round()}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Biểu đồ cột thu chi 6 tháng
  Widget _buildSixMonthChart() {
    final data = _sixMonthData;

    double maxValue = 0;

    for (final item in data) {
      maxValue = math.max(maxValue, math.max(item.income, item.expense));
    }

    if (maxValue == 0) {
      maxValue = 1;
    }

    return Column(
      children: [
        // Chú thích
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildLegend('Thu', const Color(0xFFA5D6A7)),

            const SizedBox(width: 15),

            _buildLegend('Chi', const Color(0xFFD32F2F)),
          ],
        ),

        const SizedBox(height: 18),

        // Các cột
        SizedBox(
          height: 165,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: data.map((item) {
              final incomeHeight = item.income / maxValue * 125;

              final expenseHeight = item.expense / maxValue * 125;

              final isSelected =
                  item.month.year == _selectedMonth.year &&
                  item.month.month == _selectedMonth.month;

              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar(incomeHeight, const Color(0xFFA5D6A7)),

                            const SizedBox(width: 4),

                            _buildBar(expenseHeight, const Color(0xFFD32F2F)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      'T${item.month.month}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.black : AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 14,
      height: height.clamp(0.0, 125.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    );
  }

  Widget _buildLegend(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),

        const SizedBox(width: 5),

        Text(
          title,
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
        ),
      ],
    );
  }

  // Top 3 khoản chi lớn nhất
  Widget _buildTopExpenses() {
    final expenses = _topExpenses;

    if (expenses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Chưa có khoản chi nào trong tháng này',
            style: TextStyle(color: AppTheme.textGrey),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(expenses.length, (index) {
        final transaction = expenses[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppTheme.primaryLight,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  transaction.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              const SizedBox(width: 8),

              Text(
                '-${AppData.number(transaction.amount)}',
                style: const TextStyle(
                  color: AppTheme.expense,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê'), centerTitle: true),

      body: ListenableBuilder(
        listenable: AppData.instance,

        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),

            children: [
              _buildMonthSelector(),

              _buildSummary(),

              const SizedBox(height: 20),

              _chartCard(
                title: 'Chi tiêu theo danh mục',
                child: _buildCategoryChart(),
              ),

              _chartCard(
                title: 'Thu / chi 6 tháng',
                child: _buildSixMonthChart(),
              ),

              _chartCard(
                title: 'Top 3 khoản chi lớn nhất',
                child: _buildTopExpenses(),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Model dữ liệu thống kê từng tháng
class _MonthlyData {
  final DateTime month;
  final double income;
  final double expense;

  const _MonthlyData({
    required this.month,
    required this.income,
    required this.expense,
  });
}

// Vẽ biểu đồ tròn dạng Donut
class _DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final total = values.fold<double>(0, (sum, value) => sum + value);

    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);

    final radius = math.min(size.width, size.height) / 2 - 16;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 27
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = values[i] / total * 2 * math.pi;

      paint.color = colors[i % colors.length];

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}
