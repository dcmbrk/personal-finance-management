import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_data.dart';
import 'about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const List<double> quickBudgets = [
    3000000,
    5000000,
    8000000,
    10000000,
  ];

  static const double maxBudget = 1000000000000;

  static String? validateBudget(String? input) {
    final value = AppData.parseMoney(input ?? '');

    if (value == null) return 'Vui lòng nhập số tiền';
    if (value <= 0) return 'Ngân sách phải lớn hơn 0';
    if (value > maxBudget) return 'Số tiền quá lớn';

    return null;
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController budgetController;

  AppData get data => AppData.instance;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    budgetController = TextEditingController(
      text: AppData.number(data.monthlyBudget),
    );
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  void showMessage(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void setSaving(bool value) {
    if (!mounted) return;

    setState(() {
      _isSaving = value;
    });
  }

  // Lưu ngân sách lên Firestore.
  Future<void> saveBudget() async {
    if (_isSaving) return;
    if (!formKey.currentState!.validate()) return;

    final value = AppData.parseMoney(budgetController.text)!;

    setSaving(true);

    try {
      await data.setBudget(value);

      if (!mounted) return;

      budgetController.text = AppData.number(value);

      FocusScope.of(context).unfocus();

      showMessage('Đã lưu ngân sách ${AppData.money(value)}');
    } catch (e) {
      showMessage('Không thể lưu ngân sách. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setSaving(false);
      }
    }
  }

  // Thay đổi tên hiển thị.
  Future<void> editName() async {
    if (_isSaving) return;

    var input = data.owner;

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tên hiển thị'),
        content: TextFormField(
          initialValue: input,
          onChanged: (v) => input = v,
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Nhập tên của bạn'),
          onFieldSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (name == null || !mounted) return;

    if (name.trim().isEmpty) {
      showMessage('Tên không được để trống');
      return;
    }

    setSaving(true);

    try {
      await data.setOwner(name.trim());

      showMessage('Đã cập nhật tên hiển thị');
    } catch (e) {
      showMessage('Không thể cập nhật tên. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setSaving(false);
      }
    }
  }

  Future<bool> confirm(
    String title,
    String message,
    String action, {
    bool danger = false,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            style: danger
                ? FilledButton.styleFrom(backgroundColor: AppTheme.expense)
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );

    return ok ?? false;
  }

  // Khôi phục dữ liệu mẫu trên Firestore.
  Future<void> resetSample() async {
    if (_isSaving) return;

    final ok = await confirm(
      'Khôi phục dữ liệu mẫu?',
      'Toàn bộ giao dịch, tên và ngân sách hiện tại sẽ được thay bằng dữ liệu mẫu.',
      'Khôi phục',
    );

    if (!ok || !mounted) return;

    setSaving(true);

    try {
      await data.resetSampleData();

      if (!mounted) return;

      budgetController.text = AppData.number(data.monthlyBudget);

      showMessage('Đã khôi phục dữ liệu mẫu');
    } catch (e) {
      showMessage('Không thể khôi phục dữ liệu. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setSaving(false);
      }
    }
  }

  // Xóa toàn bộ giao dịch trên Firestore.
  Future<void> clearAll() async {
    if (_isSaving) return;

    final ok = await confirm(
      'Xoá toàn bộ dữ liệu?',
      'Tất cả giao dịch sẽ bị xoá và không thể hoàn tác.',
      'Xoá',
      danger: true,
    );

    if (!ok || !mounted) return;

    setSaving(true);

    try {
      await data.clearAll();

      showMessage('Đã xoá toàn bộ giao dịch');
    } catch (e) {
      showMessage('Không thể xoá dữ liệu. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setSaving(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListenableBuilder(
        listenable: data,
        builder: (context, _) => Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(AppTheme.padding),
              children: [
                _profileCard(),
                const SizedBox(height: 16),

                _sectionTitle('NGÂN SÁCH'),
                _budgetCard(),
                const SizedBox(height: 16),

                _sectionTitle('DỮ LIỆU'),
                _box([
                  _tile(
                    icon: Icons.restore,
                    label: 'Khôi phục dữ liệu mẫu',
                    onTap: resetSample,
                  ),
                  const Divider(height: 1),
                  _tile(
                    icon: Icons.delete_outline,
                    label: 'Xoá toàn bộ dữ liệu',
                    color: AppTheme.expense,
                    onTap: clearAll,
                  ),
                ]),
                const SizedBox(height: 16),

                _sectionTitle('ỨNG DỤNG'),
                _box([
                  _tile(
                    icon: Icons.info_outline,
                    label: 'Giới thiệu nhóm',
                    trailingText: 'v1.0.0',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    ),
                  ),
                ]),
              ],
            ),

            if (_isSaving)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.08),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppTheme.textGrey,
        ),
      ),
    );
  }

  Widget _box(List<Widget> children) {
    return Material(
      color: AppTheme.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.border, width: 1.2),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(children: children),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppTheme.textDark,
    String? trailingText,
  }) {
    return ListTile(
      minTileHeight: 56,
      enabled: !_isSaving,
      leading: Icon(
        icon,
        color: color == AppTheme.textDark ? AppTheme.primary : color,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: color,
          fontWeight: color == AppTheme.textDark
              ? FontWeight.normal
              : FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
            ),
          const Icon(Icons.chevron_right, color: AppTheme.textGrey),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _profileCard() {
    final name = data.owner.trim();

    final initial = name.isEmpty ? '?' : name.split(RegExp(r'\s+')).last[0];

    return _box([
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              child: Text(
                initial.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.owner,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Tên hiển thị trên Trang chủ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Sửa tên',
              onPressed: _isSaving ? null : editName,
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _budgetCard() {
    final current = data.monthlyBudget;

    return _box([
      Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ngân sách mỗi tháng',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              TextFormField(
                key: const Key('budgetField'),
                controller: budgetController,
                enabled: !_isSaving,
                keyboardType: TextInputType.number,
                validator: SettingsPage.validateBudget,
                onFieldSubmitted: (_) => saveBudget(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  suffixText: AppData.currency,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppTheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SettingsPage.quickBudgets.map((v) {
                  return ChoiceChip(
                    label: Text(AppData.number(v)),
                    selected: v == current,
                    selectedColor: AppTheme.primaryLight,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: v == current
                          ? AppTheme.primary
                          : AppTheme.textDark,
                    ),
                    onSelected: _isSaving
                        ? null
                        : (_) {
                            budgetController.text = AppData.number(v);
                            saveBudget();
                          },
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              const Text(
                'Cảnh báo màu cam khi chi tiêu đạt 80% và màu đỏ khi vượt 100%.',
                style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
              ),

              const SizedBox(height: 12),

              FilledButton(
                onPressed: _isSaving ? null : saveBudget,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Lưu ngân sách',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
