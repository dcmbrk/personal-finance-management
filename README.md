# personal_finance

Ứng dụng quản lý chi tiêu cá nhân (bài tập lớn môn Lập trình Flutter).

## Bài tập thực hành số 4 - Thiết kế giao diện

### 1. Thống nhất thiết kế (Design System)

File `lib/AppTheme.dart` chứa toàn bộ quy ước dùng chung cho mọi màn hình.

**Màu sắc**

| Tên | Mã màu | Sử dụng |
|---|---|---|
| primary | `#2E7D32` | AppBar, nút, icon được chọn |
| primaryLight | `#E8F5E9` | Nền chip danh mục, avatar |
| accent | `#FFA000` | Nhấn mạnh |
| background | `#F6F7F9` | Nền trang |
| card | `#FFFFFF` | Nền thẻ |
| textDark | `#1B1B1B` | Chữ chính |
| textGrey | `#6B7280` | Chữ phụ |
| expense | `#D32F2F` | Khoản chi |
| income | `#2E7D32` | Khoản thu |

**Font chữ:** Roboto — titleLarge 20 bold, titleMedium 16 w600, bodyMedium 14, bodySmall 12 (màu xám).

**Khoảng cách & bo góc:** padding 16, radius 12, card elevation 1.

### 2. Mockup & Layout 3 màn hình

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Trang chủ     │  │   Giao dịch     │  │   Giới thiệu    │
├─────────────────┤  ├─────────────────┤  ├─────────────────┤
│ ┌─────────────┐ │  │ (Tất cả)(Ăn..)  │  │       ◯         │
│ │  Số dư      │ │  ├─────────────────┤  │ Personal Finance│
│ │  5.630.000  │ │  │ ◯ Lương  +8.000 │  │   v1.0.0        │
│ │ Thu ▲  Chi ▼│ │  │ ◯ Ăn uống -450  │  ├─────────────────┤
│ └─────────────┘ │  │ ◯ Hóa đơn -120  │  │ Giới thiệu      │
│ Ngân sách       │  │ ◯ Học tập -1.500│  │ [   mô tả    ]  │
│ ▓▓▓▓▓░░░░ 47%   │  │ ◯ Xăng xe -300  │  │ Chức năng chính │
│ Danh mục        │  │                 │  │ ✓ ...           │
│ (Ăn)(Đi)(Mua)   │  │                 │  │ Thành viên nhóm │
│ Giao dịch gần đây│ │                 │  │ ◯ Lê Duy Tùng   │
│ ◯ ... -300.000  │  │                 │  │ ◯ Đỗ Công Minh  │
├─────────────────┤  ├─────────────────┤  ├─────────────────┤
│ 🏠   📄   ℹ️     │  │ 🏠   📄   ℹ️     │  │ 🏠   📄   ℹ️     │
│Home Content About│ │Home Content About│ │Home Content About│
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

- **Home** (`lib/HomePage.dart`): thẻ số dư, tiến độ ngân sách, chip danh mục, giao dịch gần đây.
- **Content** (`lib/ContentPage.dart`): danh sách toàn bộ giao dịch, lọc theo danh mục bằng ChoiceChip.
- **About** (`lib/AboutPage.dart`): thông tin ứng dụng, chức năng chính, thành viên nhóm.

### 3. Code chính phần Layout

```dart
Scaffold(
  appBar: AppBar(title: const Text('Trang chủ')),
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(AppTheme.padding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Số dư hiện tại'),
              Text(AppData.money(AppData.transactions.balance)),
              Row(children: [Expanded(child: _Summary(...)), Expanded(child: _Summary(...))]),
            ],
          ),
        ),
        LinearProgressIndicator(value: percent),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: chips)),
        ...recent.map((t) => Card(child: ListTile(...))),
      ],
    ),
  ),
)
```

### 4. Code chính của Navigation Bar

File `lib/MainScreen.dart`:

```dart
class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [HomePage(), ContentPage(), AboutPage()];

  void onTap(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Content',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            activeIcon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
```

Cấu hình dùng chung trong `AppTheme`:

```dart
bottomNavigationBarTheme: const BottomNavigationBarThemeData(
  backgroundColor: Colors.white,
  selectedItemColor: primary,
  unselectedItemColor: textGrey,
  type: BottomNavigationBarType.fixed,
  showUnselectedLabels: true,
),
```

`IndexedStack` giữ nguyên trạng thái của từng trang khi chuyển tab.

### 5. Ảnh chụp màn hình

| Home | Content | About |
|---|---|---|
| ![Home](screenshots/home.png) | ![Content](screenshots/content.png) | ![About](screenshots/about.png) |

## Cấu trúc thư mục

```
lib/
├── main.dart
├── AppTheme.dart
├── AppData.dart
├── MainScreen.dart
├── HomePage.dart
├── ContentPage.dart
├── AboutPage.dart
├── GenericBox.dart
├── Transaction.dart
└── ListTransaction.dart
```

## Chạy ứng dụng

```
flutter pub get
flutter run
```
