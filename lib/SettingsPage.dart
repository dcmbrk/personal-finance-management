import 'package:flutter/material.dart';
import 'AppTheme.dart';

// Màn hình Cài đặt - Lưu Quang Trung phụ trách.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: const Center(
        child: Text('Đang phát triển', style: TextStyle(color: AppTheme.textGrey)),
      ),
    );
  }
}
