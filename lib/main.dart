import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Finance',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Personal Finance'),
          backgroundColor: Colors.green,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'THÀNH VIÊN NHÓM',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text('1. Lê Duy Tùng - MSSV: 23010287', style: TextStyle(fontSize: 16)),
              Text('2. Đỗ Công Minh - MSSV: 24100036', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}