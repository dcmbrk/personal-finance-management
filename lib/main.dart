import 'package:flutter/material.dart';
import 'AppTheme.dart';
import 'MainScreen.dart';

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
      theme: AppTheme.theme,
      home: const MainScreen(),
    );
  }
}
