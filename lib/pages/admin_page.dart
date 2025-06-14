import 'package:flutter/material.dart';
import '../models/data_service.dart';
import '../services/auth_service.dart';
import 'post_page.dart';
import 'rekap_page.dart';
import 'notulensi_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'profile_settings_page.dart';
import 'package:flutter/services.dart'; // Untuk Clipboard

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _expiredCtrl = TextEditingController(text: '30'); // default 30 menit
  final _authService = AuthService();

  void _generateNewToken() {
    final minutes = int.tryParse(_expiredCtrl.text.trim()) ?? 30;
    if (minutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Durasi token harus lebih dari 0 menit.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }
    DataService.generateToken(expiredMinutes: minutes);
    setState(() {}); // Untuk memperbarui tampilan token aktif
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Token baru dibuat: ${DataService.activeToken} (Berlaku hingga ${DataService.getTokenExpireInfo()})',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _expiredCtrl.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColorDark,
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required String title,
    required IconData icon,
    Widget? subtitle,
    List<Widget>? actions,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(
                  left: 40.0,
                ), // Align with title text
                child: subtitle,
              ),
            ],
            if (actions != null && actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(
                  left: 40.0,
                ), // Align with title text
                child: Wrap(
                  // Use Wrap for actions if they might overflow
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: actions,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.blueAccent,
        elevation: 1,
        // Tombol kembali ke home dan logout bisa tetap di AppBar jika diinginkan
        // atau dipindahkan sepenuhnya ke Drawer
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white70,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 30,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _authService.currentUser?.nama ?? 'Administrator',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _authService.currentUser?.divisi ?? 'Admin Panel',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Beranda'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.vpn_key_outlined),
              title: const Text('Token Absensi'),
              // subtitle: const Text('Kelola token untuk absensi'), // Bisa dihilangkan jika judul sudah jelas
              onTap: () {
                Navigator.pop(context);
                // Anda bisa menambahkan GlobalKey ke widget _buildAdminCard token
                // dan menggunakan Scrollable.ensureVisible untuk scroll ke sana.
                // Untuk saat ini, hanya menutup drawer.
              },
            ),
            ListTile(
              leading: const Icon(Icons.post_add_outlined),
              title: const Text('Posting Konten'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_alt_outlined),
              title: const Text('Notulensi Rapat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotulensiPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment_outlined),
              title: const Text('Rekap Absensi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RekapPage(isAdmin: true)),
                );
              },
            ),
            // --- TAMBAHKAN ListTile UNTUK PENGATURAN PROFIL ---
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Pengaturan Profil'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileSettingsPage(),
                  ),
                ).then((_) {
                  // Jika ada perubahan pada profil yang mempengaruhi tampilan di drawer (misal nama),
                  // panggil setState di sini untuk memperbarui drawer.
                  if (mounted) {
                    setState(() {});
                  }
                });
              },
            ),
            // --- AKHIR PENAMBAHAN ---
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Logout'),
              onTap: () {
                _authService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildAdminCard(
              title: 'Manajemen Token Absensi',
              icon: Icons.vpn_key_outlined,
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _expiredCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Durasi Token (menit)',
                      hintText: "Contoh: 30",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.timer_outlined),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (DataService.activeToken != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                'Token Aktif: ${DataService.activeToken}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Berlaku hingga: ${DataService.getTokenExpireInfo()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          color: Colors.blueAccent,
                          tooltip: 'Salin token',
                          onPressed: () {
                            // Copy token ke clipboard
                            Clipboard.setData(
                              ClipboardData(
                                text: DataService.activeToken ?? '',
                              ),
                            );
                            // Tampilkan feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Token berhasil disalin!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  else
                    Text(
                      'Belum ada token aktif.',
                      style: TextStyle(fontSize: 14, color: Colors.blue[600]),
                    ),
                ],
              ),
              actions: [
                _buildActionButton(
                  'Generate Token',
                  Icons.add_circle_outline,
                  _generateNewToken,
                ),
              ],
            ),
            _buildSectionTitle('Manajemen Konten'),
            _buildAdminCard(
              title: 'Posting Konten',
              icon: Icons.post_add_outlined,
              actions: [
                _buildActionButton(
                  'Berita & Agenda',
                  Icons.article_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PostPage()),
                    ).then(
                      (_) => setState(() {}),
                    ); // Refresh data jika ada perubahan
                  },
                ),
                const SizedBox(width: 8), // Spacing between buttons
                _buildActionButton(
                  'Notulensi Rapat',
                  Icons.note_alt_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotulensiPage()),
                    ).then(
                      (_) => setState(() {}),
                    ); // Refresh data jika ada perubahan
                  },
                ),
              ],
            ),
            _buildSectionTitle('Rekapitulasi'),
            _buildAdminCard(
              title: 'Laporan & Rekap',
              icon: Icons.assessment_outlined,
              actions: [
                _buildActionButton(
                  'Rekap Absensi',
                  Icons.checklist_rtl_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RekapPage(isAdmin: true),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
