enum UserRole { admin, member }

class UserModel {
  final String id;
  final String email;
  final String password;
  final String nama;
  final UserRole role;
  final String? asalKampus;
  final String? divisi;
  final DateTime? tanggalLahir;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.nama,
    required this.role,
    this.asalKampus,
    this.divisi,
    this.tanggalLahir,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isMember => role == UserRole.member;
}
