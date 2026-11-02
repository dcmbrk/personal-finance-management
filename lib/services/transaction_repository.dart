import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';

import '../app_data.dart';
import '../transaction.dart';

class TransactionRepository {
  TransactionRepository._();

  static final TransactionRepository instance = TransactionRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy Collection giao dịch theo Firebase Authentication UID.
  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) {
    return _userRef(uid).collection('transactions');
  }

  /// Lấy Document hồ sơ người dùng theo Firebase Authentication UID.
  DocumentReference<Map<String, dynamic>> _userRef(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  /// Lấy UID của tài khoản đang đăng nhập.
  String get _uid {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Người dùng chưa đăng nhập.');
    }

    return user.uid;
  }

  /// Tải thông tin hồ sơ người dùng.
  Future<Map<String, dynamic>> loadUserData() async {
    final uid = _uid;
    final userRef = _userRef(uid);

    final userSnapshot = await userRef.get();

    if (!userSnapshot.exists) {
      final user = FirebaseAuth.instance.currentUser;
      final displayName = user?.displayName?.trim() ?? '';

      final defaultData = {
        'owner': displayName.isNotEmpty ? displayName : AppData.defaultOwner,
        'monthlyBudget': AppData.defaultBudget,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await userRef.set(defaultData);

      return {
        'owner': defaultData['owner'],
        'monthlyBudget': defaultData['monthlyBudget'],
        '_isNewUser': true,
      };
    }

    final data = userSnapshot.data() ?? {};

    return {
      'owner': data['owner'] ?? AppData.defaultOwner,
      'monthlyBudget':
          (data['monthlyBudget'] as num?)?.toDouble() ?? AppData.defaultBudget,
      '_isNewUser': false,
    };
  }

  /// Tải danh sách giao dịch của người dùng.
  Future<List<Transaction>> loadTransactions() async {
    final snapshot = await _transactionsRef(_uid)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Transaction.fromMap({...data, 'id': doc.id});
    }).toList();
  }

  /// Thêm giao dịch mới.
  Future<void> addTransaction(Transaction transaction) async {
    await _transactionsRef(_uid).doc(transaction.id).set(transaction.toMap());
  }

  /// Cập nhật giao dịch.
  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionsRef(_uid)
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  /// Xóa giao dịch theo ID.
  Future<void> deleteTransaction(String id) async {
    await _transactionsRef(_uid).doc(id).delete();
  }

  /// Cập nhật thông tin hồ sơ người dùng.
  Future<void> updateUserData({String? owner, double? monthlyBudget}) async {
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};

    if (owner != null) {
      data['owner'] = owner;
    }

    if (monthlyBudget != null) {
      data['monthlyBudget'] = monthlyBudget;
    }

    await _userRef(_uid).set(data, SetOptions(merge: true));
  }

  /// Xóa toàn bộ giao dịch.
  Future<void> clearTransactions() async {
    final collection = _transactionsRef(_uid);
    final snapshot = await collection.get();

    for (var i = 0; i < snapshot.docs.length; i += 500) {
      final batch = _firestore.batch();

      final end = (i + 500 < snapshot.docs.length)
          ? i + 500
          : snapshot.docs.length;

      for (var j = i; j < end; j++) {
        batch.delete(snapshot.docs[j].reference);
      }

      await batch.commit();
    }
  }

  /// Thay thế toàn bộ danh sách giao dịch.
  Future<void> replaceTransactions(List<Transaction> transactions) async {
    await clearTransactions();

    final collection = _transactionsRef(_uid);

    for (var i = 0; i < transactions.length; i += 500) {
      final batch = _firestore.batch();

      final end = (i + 500 < transactions.length)
          ? i + 500
          : transactions.length;

      for (var j = i; j < end; j++) {
        final transaction = transactions[j];

        batch.set(collection.doc(transaction.id), transaction.toMap());
      }

      await batch.commit();
    }
  }
}
