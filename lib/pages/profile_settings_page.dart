import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import '../services/auth_service.dart'; // Sesuaikan path jika perlu
import '../models/user_model.dart'; // Sesuaikan path jika perlu

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmNewPasswordController;

  DateTime? _selectedDateOfBirth;
  UserModel? _currentUser;

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;

    _namaController = TextEditingController(text: _currentUser?.nama ?? '');
    // Email biasanya tidak diubah atau memerlukan verifikasi khusus,
    // jadi kita tampilkan saja atau buat read-only.
    // Untuk contoh ini, kita buat bisa diedit.
    _emailController = TextEditingController(
      text: _currentUser?.email ?? '',
    ); // Asumsi username adalah email

    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();

    // Contoh: Jika UserModel Anda memiliki field tanggalLahir
    // if (_currentUser?.tanggalLahir != null) {
    //   _selectedDateOfBirth = _currentUser!.tanggalLahir;
    // }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    // Simulasi penyimpanan
    await Future.delayed(const Duration(seconds: 1));

    if (_currentUser != null) {
      // Buat UserModel baru dengan data yang diperbarui
      // Anda perlu menambahkan field seperti email dan tanggalLahir ke UserModel jika belum ada
      // dan mekanisme untuk memperbarui user di AuthService
      // Contoh:
      // final updatedUser = UserModel(
      //   id: _currentUser!.id,
      //   username: _emailController.text.trim(), // Jika email adalah username
      //   password: _currentUser!.password, // Password tidak diubah di sini
      //   nama: _namaController.text.trim(),
      //   role: _currentUser!.role,
      //   asalKampus: _currentUser!.asalKampus,
      //   divisi: _currentUser!.divisi,
      //   // tanggalLahir: _selectedDateOfBirth, // Tambahkan jika ada
      // );

      // _authService.updateUser(updatedUser); // Anda perlu implementasi updateUser di AuthService

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui profil: User tidak ditemukan.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _changePassword() async {
    // Validasi field password
    if (_newPasswordController.text.isEmpty ||
        _confirmNewPasswordController.text.isEmpty ||
        _currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field password harus diisi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password baru tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi penggantian password
    // Di aplikasi nyata, Anda akan memvalidasi _currentPasswordController.text dengan password user saat ini
    // dan kemudian menggantinya dengan _newPasswordController.text
    await Future.delayed(const Duration(seconds: 1));

    // Contoh:
    // bool passwordChanged = await _authService.changePassword(
    //   _currentUser!.id,
    //   _currentPasswordController.text,
    //   _newPasswordController.text,
    // );

    // if (passwordChanged) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password berhasil diubah! (Simulasi)'),
        backgroundColor: Colors.green,
      ),
    );
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmNewPasswordController.clear();
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Gagal mengubah password. Password saat ini salah? (Simulasi)'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Profil'),
        backgroundColor: Colors.blue,
      ),
      body:
          _currentUser == null
              ? const Center(child: Text('User tidak ditemukan.'))
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildSectionTitle('Informasi Akun'),
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email (Username)',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey,
                      ),
                      title: Text(
                        _selectedDateOfBirth == null
                            ? 'Pilih Tanggal Lahir'
                            : 'Tanggal Lahir: ${DateFormat('dd MMMM yyyy').format(_selectedDateOfBirth!)}',
                      ),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _pickDateOfBirth(context),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.save_outlined),
                      label: const Text('Simpan Perubahan Profil'),
                      onPressed: _isLoading ? null : _saveProfileChanges,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const Divider(height: 40, thickness: 1),
                    _buildSectionTitle('Ubah Password'),
                    TextFormField(
                      controller: _currentPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Password Saat Ini',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureCurrentPassword,
                      validator: (value) {
                        // Validasi bisa ditambahkan jika diperlukan saat submit form utama
                        // Namun, validasi utama ada di _changePassword
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureNewPassword,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmNewPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password Baru',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value != null &&
                            _newPasswordController.text.isNotEmpty &&
                            value != _newPasswordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.key_outlined),
                      label: const Text('Ubah Password'),
                      onPressed: _isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
