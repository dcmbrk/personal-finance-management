import 'package:flutter/material.dart';
import 'AppTheme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const List<Map<String, String>> members = [
    {'name': 'Lê Duy Tùng', 'id': '23010287'},
    {'name': 'Đỗ Công Minh', 'id': '24100036'},
  ];

  static const List<String> features = [
    'Quản lý các khoản thu và chi hằng ngày',
    'Phân loại giao dịch theo danh mục',
    'Theo dõi ngân sách và cảnh báo vượt chi',
    'Thống kê số dư, tổng thu, tổng chi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giới thiệu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 44,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Personal Finance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phiên bản 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Giới thiệu', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Ứng dụng quản lý tài chính cá nhân giúp người dùng ghi lại '
                  'các khoản thu chi, phân loại theo danh mục và theo dõi ngân '
                  'sách hằng tháng. Đây là sản phẩm bài tập lớn môn Lập trình '
                  'Flutter.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Chức năng chính', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: features.map((f) {
                  return ListTile(
                    leading: const Icon(Icons.check_circle, color: AppTheme.primary),
                    title: Text(f),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Text('Thành viên nhóm', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: members.map((m) {
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.person),
                    ),
                    title: Text(m['name']!),
                    subtitle: Text('MSSV: ${m['id']}'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
