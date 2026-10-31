import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name.trim());

    await credential.user?.reload();

    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  String getErrorMessage(Object error) {
    if (error is! FirebaseAuthException) {
      return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }

    switch (error.code) {
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ.';

      case 'user-not-found':
        return 'Không tìm thấy tài khoản này.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không chính xác.';

      case 'email-already-in-use':
        return 'Email này đã được đăng ký.';

      case 'weak-password':
        return 'Mật khẩu quá yếu. Hãy sử dụng ít nhất 6 ký tự.';

      case 'too-many-requests':
        return 'Bạn đã thử quá nhiều lần. Vui lòng thử lại sau.';

      case 'network-request-failed':
        return 'Không thể kết nối mạng. Vui lòng kiểm tra Internet.';

      case 'operation-not-allowed':
        return 'Phương thức đăng nhập chưa được bật trên Firebase.';

      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';

      default:
        return error.message ?? 'Đã xảy ra lỗi xác thực.';
    }
  }
}
