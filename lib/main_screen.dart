import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_data.dart';
import 'home_page.dart';
import 'content_page.dart';
import 'statistics_page.dart';
import 'settings_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  void onTap(int index) {
    setState(() => currentIndex = index);
  }

  void openCategory(String category) {
    AppData.instance.categoryFilter.value = category;
    onTap(1);
  }

  void openAllTransactions() {
    AppData.instance.categoryFilter.value = AppData.allCategories;
    onTap(1);
  }

  BottomNavigationBarItem navItem(
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: SizedBox(width: 60, height: 28, child: Icon(icon, size: 21)),
      activeIcon: Container(
        width: 60,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Icon(activeIcon, size: 21),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onSeeAll: openAllTransactions, onCategoryTap: openCategory),
      const ContentPage(),
      const StatisticsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          navItem(Icons.home_outlined, Icons.home, 'Trang chủ'),
          navItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Giao dịch'),
          navItem(Icons.bar_chart_outlined, Icons.bar_chart, 'Thống kê'),
          navItem(Icons.settings_outlined, Icons.settings, 'Cài đặt'),
        ],
      ),
    );
  }
}
