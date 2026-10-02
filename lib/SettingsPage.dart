import 'package:flutter/material.dart';
import 'AppTheme.dart';

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
