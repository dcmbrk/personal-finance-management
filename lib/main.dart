import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    String currency = "VNĐ";
    double monthlyBudget = 5000000;
    int totalTransactions = 12;
    bool isOverBudget = false;

    List<String> categories = ["Ăn uống", "Di chuyển", "Mua sắm", "Học tập"];
    Map<String, String> accountInfo = {
      "owner": "Lê Duy Minh",
      "type": "Tài khoản cá nhân"
    };

    List<Map<String, dynamic>> listFinance = [
      {'id': 1, 'name': 'Chi tiêu Ăn uống hàng ngày'},
      {'id': 2, 'name': 'Thanh toán Hóa đơn di động'},
      {'id': 3, 'name': 'Mua tài liệu & Học phí Flutter'},
      {'id': 4, 'name': 'Chi phí Xăng xe & Di chuyển'},
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Finance',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Personal Finance'),
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Center(
                child: Column(
                  children: [
                    Text(
                      'THÀNH VIÊN NHÓM',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text('1. Lê Duy Tùng - MSSV: 23010287', style: TextStyle(fontSize: 14)),
                    Text('2. Đỗ Công Minh - MSSV: 24100036', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const Divider(height: 24),

              const Text(
                '1. Thông tin ngân sách:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text('Ngân sách tháng: ${monthlyBudget.toStringAsFixed(0)} $currency'),
              Text('Số giao dịch phát sinh: $totalTransactions'),
              Text('Cảnh báo vượt chi: ${isOverBudget ? "Có" : "Không"}'),
              const Divider(height: 24),

              const Text(
                '2. Danh mục tài chính:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              Text('Chủ tài khoản: ${accountInfo['owner']}'),
              const Divider(height: 24),

              const Text(
                '3. Danh sách mục quản lý:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...listFinance.map((item) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      child: Text('${item['id']}'),
                    ),
                    title: Text(item['name']),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}