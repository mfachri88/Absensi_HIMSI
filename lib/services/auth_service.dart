import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Data dummy users untuk demonstrasi
  final List<UserModel> _users = [
    UserModel(
      id: '1',
      email: 'admin@gmail.com',
      password: '1',
      nama: 'Administrator',
      role: UserRole.admin,
      asalKampus: 'Cutmutia',
      divisi: 'Admin',
      tanggalLahir: DateTime(2000, 1, 1),
    ),
    UserModel(
      id: '2',
      email: 'sekre@gmail.com',
      password: 'sekre123',
      nama: 'Sekretaris',
      role: UserRole.admin,
      asalKampus: 'Cutmutia',
      divisi: 'Sekretaris',
      tanggalLahir: DateTime(2000, 1, 1),
    ),
    UserModel(
      id: '3',
      email: 'fachri@gmail.com',
      password: '1',
      nama: 'fachri',
      role: UserRole.member,
      asalKampus: 'CutMutia',
      divisi: 'Ketua DPC',
      tanggalLahir: DateTime(2004, 6, 29),
    ),
    UserModel(
      id: '4',
      email: 'maman@gmail.com',
      password: 'maman123',
      nama: 'M Rochman',
      role: UserRole.member,
      asalKampus: 'CutMutia',
      divisi: 'Anggota Litbang',
      tanggalLahir: DateTime(2000, 9, 29),
    ),
  ];

  // Method untuk login
  Future<bool> login(String email, String password) async {
    // Simulasi delay network
    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = _users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      _currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Method untuk logout
  void logout() {
    _currentUser = null;
  }

  // Method untuk check apakah user sudah login
  bool get isLoggedIn => _currentUser != null;

  // Method untuk mendapatkan role user saat ini
  UserRole? get currentUserRole => _currentUser?.role;

  // Method untuk check apakah user adalah admin
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Method untuk check apakah user adalah member
  bool get isMember => _currentUser?.isMember ?? false;

  // Method untuk mendapatkan semua users (untuk admin)
  List<UserModel> getAllUsers() {
    return _users;
  }

  // Method untuk menambah user baru (untuk admin)
  void addUser(UserModel user) {
    _users.add(user);
  }

  // Method untuk update user (untuk admin)
  void updateUser(UserModel updatedUser) {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
    }
  }

  // Method untuk delete user (untuk admin)
  void deleteUser(String userId) {
    _users.removeWhere((user) => user.id == userId);
  }
}
