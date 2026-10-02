import 'package:flutter/material.dart';
import 'AppTheme.dart';

// Màn hình Thống kê - Đỗ Công Minh phụ trách.
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: const Center(
        child: Text('Đang phát triển', style: TextStyle(color: AppTheme.textGrey)),
      ),
    );
  }
}
