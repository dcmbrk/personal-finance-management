import 'package:flutter/material.dart';
import 'AppTheme.dart';

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
