import 'package:flutter/material.dart';
import '../models/data_service.dart';
import '../models/absen_model.dart';
import '../services/auth_service.dart';
//import 'rekap_page.dart';
import 'home_page.dart';

class AbsensiForm extends StatefulWidget {
  const AbsensiForm({super.key});

  @override
  State<AbsensiForm> createState() => _AbsensiFormState();
}

class _AbsensiFormState extends State<AbsensiForm> {
  final _formKey = GlobalKey<FormState>();
  final _tokenCtrl = TextEditingController();
  final _kegiatanLainCtrl = TextEditingController();
  final _tugasCtrl = TextEditingController();
  final _authService = AuthService();

  // Data user dari AuthService
  late String _nama = '';
  late String _asalKampus = '';
  late String _divisi = '';

  String _kegiatan = 'Rapat';

  final List<String> _kegiatanOptions = ['Rapat', 'Event', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    // Ambil data pengguna dari AuthService saat form dimuat
    _loadUserData();
  }

  void _loadUserData() {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      setState(() {
        _nama = currentUser.nama;
        _asalKampus = currentUser.asalKampus ?? '';
        _divisi = currentUser.divisi ?? '';
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final token = _tokenCtrl.text.trim();
      final currentUser = _authService.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus login terlebih dahulu!'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Validasi token untuk user ini
      if (!DataService.isTokenValidForUser(token, currentUser.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Token tidak valid, sudah kadaluarsa, atau sudah Anda gunakan sebelumnya!',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Tandai token sebagai sudah digunakan oleh user ini
      DataService.markTokenAsUsedByUser(token, currentUser.id);

      // Proses absensi seperti biasa
      DataService.absensiList.add(
        AbsenModel(
          nama: _nama,
          asalKampus: _asalKampus,
          timestamp: DateTime.now(),
          kegiatan:
              _kegiatan == 'Lainnya'
                  ? _kegiatanLainCtrl.text.trim()
                  : _kegiatan,
          kegiatanLain:
              _kegiatan == 'Lainnya' ? _kegiatanLainCtrl.text.trim() : '',
          divisi: _divisi,
          tugas: _tugasCtrl.text.trim(),
          token: token,
        ),
      );

      // Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Absensi berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );

      // Arahkan ke Beranda setelah jeda singkat
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek jika user belum login
    if (_authService.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Form Absensi'),
          backgroundColor: Colors.blue,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Silakan login terlebih dahulu',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text('Pergi ke Halaman Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Absensi'),
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Informasi Kegiatan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _kegiatan,
                        decoration: InputDecoration(
                          labelText: 'Jenis Kegiatan',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        items:
                            _kegiatanOptions.map((String option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _kegiatan = value!;
                          });
                        },
                      ),
                      if (_kegiatan == 'Lainnya') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _kegiatanLainCtrl,
                          decoration: InputDecoration(
                            labelText: 'Sebutkan Kegiatan',
                            prefixIcon: const Icon(Icons.description_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          validator: (value) {
                            if (_kegiatan == 'Lainnya' &&
                                (value == null || value.isEmpty)) {
                              return 'Silakan isi jenis kegiatan';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tugasCtrl,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi Tugas',
                          prefixIcon: const Icon(Icons.assignment_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Silakan isi deskripsi tugas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tokenCtrl,
                        decoration: InputDecoration(
                          labelText: 'Token Kehadiran',
                          prefixIcon: const Icon(Icons.key_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Silakan masukkan token kehadiran';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Kirim Absensi',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _kegiatanLainCtrl.dispose();
    _tugasCtrl.dispose();
    super.dispose();
  }
}
