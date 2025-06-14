import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import '../models/post_model.dart';
import '../models/data_service.dart';
import '../services/auth_service.dart';
import 'absensi_form.dart';
import 'lihat_berita_page.dart';
import 'lihat_agenda_page.dart';
import 'admin_page.dart';
import 'detail_post_page.dart';
import 'login_page.dart';
import 'notulensi_page.dart';
import 'profile_settings_page.dart';
import 'rekap_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  List<PostModel> _beritaList = [];

  // Variabel untuk Agenda
  late PageController _agendaPageController;
  int _currentAgendaPage = 0;
  Timer? _agendaTimer;
  List<PostModel> _agendaList = [];

  @override
  void initState() {
    super.initState();
    _loadData(); // Panggil method untuk memuat data

    _pageController = PageController(initialPage: 0, viewportFraction: 0.85);
    _agendaPageController = PageController(
      initialPage: 0,
      viewportFraction: 0.85,
    );

    _initializeBeritaTimer();
    _initializeAgendaTimer();
  }

  void _loadData() {
    // Memuat data dari DataService
    // Pastikan DataService.init() sudah dipanggil di main.dart
    _beritaList =
        DataService.posts.where((post) => post.category == "Berita").toList();
    _agendaList =
        DataService.posts.where((post) => post.category == "Agenda").toList();
  }

  void _reloadDataAndTimers() {
    if (mounted) {
      setState(() {
        _loadData(); // Muat ulang data

        // Reset dan inisialisasi ulang timer untuk Berita
        if (_beritaList.isNotEmpty && _currentPage >= _beritaList.length) {
          _currentPage = 0;
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
        } else if (_beritaList.isEmpty) {
          _currentPage = 0;
        }
        _initializeBeritaTimer();

        // Reset dan inisialisasi ulang timer untuk Agenda
        if (_agendaList.isNotEmpty &&
            _currentAgendaPage >= _agendaList.length) {
          _currentAgendaPage = 0;
          if (_agendaPageController.hasClients) {
            _agendaPageController.jumpToPage(0);
          }
        } else if (_agendaList.isEmpty) {
          _currentAgendaPage = 0;
        }
        _initializeAgendaTimer();
      });
    }
  }

  void _initializeBeritaTimer() {
    _timer?.cancel();
    if (_beritaList.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (!mounted) return;
        if (_currentPage < _beritaList.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOutSine,
          );
        }
      });
    }
  }

  void _initializeAgendaTimer() {
    _agendaTimer?.cancel();
    if (_agendaList.length > 1) {
      _agendaTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (!mounted) return;
        if (_currentAgendaPage < _agendaList.length - 1) {
          _currentAgendaPage++;
        } else {
          _currentAgendaPage = 0;
        }
        if (_agendaPageController.hasClients) {
          _agendaPageController.animateToPage(
            _currentAgendaPage,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOutSine,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _agendaTimer?.cancel();
    _agendaPageController.dispose();
    super.dispose();
  }

  Widget _buildCarouselImage(PostModel post, BuildContext context) {
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      Widget imageWidget;
      if (post.imageUrl!.startsWith('assets/')) {
        imageWidget = Image.asset(
          post.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                color: Colors.white70,
                size: 40,
              ),
        );
      } else if (post.imageUrl!.startsWith('http')) {
        imageWidget = Image.network(
          post.imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.0),
            );
          },
          errorBuilder:
              (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                color: Colors.white70,
                size: 40,
              ),
        );
      } else {
        final file = File(post.imageUrl!);
        if (file.existsSync()) {
          imageWidget = Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.white70,
                  size: 40,
                ),
          );
        } else {
          imageWidget = const Icon(
            Icons.hide_image_outlined,
            color: Colors.white70,
            size: 40,
          );
        }
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: imageWidget,
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[350],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white70, size: 50),
      ),
    );
  }

  Widget _buildNewsCarousel() {
    if (_beritaList.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Tidak ada berita terbaru saat ini.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            "Berita Terbaru",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _beritaList.length,
            onPageChanged: (int page) {
              if (mounted) {
                setState(() {
                  _currentPage = page;
                });
              }
            },
            itemBuilder: (context, index) {
              final berita = _beritaList[index];
              final bool isActive = index == _currentPage;
              final double scale = isActive ? 1.0 : 0.9;
              final double opacity = isActive ? 1.0 : 0.6;

              return AnimatedScale(
                duration: const Duration(milliseconds: 350),
                scale: scale,
                child: GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPostPage(post: berita),
                        ),
                      ).then(
                        (_) => _reloadDataAndTimers(),
                      ), // Muat ulang data setelah kembali
                  child: Opacity(
                    opacity: opacity,
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 10.0,
                      ),
                      elevation: isActive ? 8 : 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: _buildCarouselImage(berita, context),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.0, 0.4, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16.0,
                            left: 16.0,
                            right: 16.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  berita.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 2.0,
                                        color: Colors.black54,
                                        offset: Offset(1.0, 1.0),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  berita.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_beritaList.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_beritaList.length, (index) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 3.0,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.4),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildAgendaCarousel() {
    if (_agendaList.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Tidak ada agenda terbaru saat ini.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            "Next Agenda",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _agendaPageController,
            itemCount: _agendaList.length,
            onPageChanged: (int page) {
              if (mounted) {
                setState(() {
                  _currentAgendaPage = page;
                });
              }
            },
            itemBuilder: (context, index) {
              final agenda = _agendaList[index];
              final bool isActive = index == _currentAgendaPage;
              final double scale = isActive ? 1.0 : 0.9;
              final double opacity = isActive ? 1.0 : 0.6;

              return AnimatedScale(
                duration: const Duration(milliseconds: 350),
                scale: scale,
                child: GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPostPage(post: agenda),
                        ),
                      ).then(
                        (_) => _reloadDataAndTimers(),
                      ), // Muat ulang data setelah kembali
                  child: Opacity(
                    opacity: opacity,
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 10.0,
                      ),
                      elevation: isActive ? 8 : 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: _buildCarouselImage(agenda, context),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.0, 0.4, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16.0,
                            left: 16.0,
                            right: 16.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  agenda.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 2.0,
                                        color: Colors.black54,
                                        offset: Offset(1.0, 1.0),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  agenda.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_agendaList.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_agendaList.length, (index) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 3.0,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentAgendaPage == index
                          ? Theme.of(context).primaryColorDark
                          : Colors.grey.withOpacity(0.4),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        backgroundColor: Colors.blueAccent,
        elevation: 1,
        actions: [
          if (_authService.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPage()),
                ).then(
                  (_) => _reloadDataAndTimers(),
                ); // Muat ulang data setelah kembali dari admin page
              },
              tooltip: 'Admin Panel',
            ),
        ],
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
                    child: Icon(Icons.person, size: 30, color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _authService.currentUser?.nama ?? 'Nama Pengguna',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _authService.currentUser?.divisi ?? 'Divisi Pengguna',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            if (_authService.isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text('Admin Panel'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminPage()),
                  ).then(
                    (_) => _reloadDataAndTimers(),
                  ); // Muat ulang data setelah kembali
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
              leading: const Icon(Icons.logout),
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
        color: Colors.grey[50],
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          children: [
            _buildNewsCarousel(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                children: [
                  _buildActionCard(
                    title: 'Semua Berita',
                    icon: Icons.article_outlined,
                    color: Colors.orangeAccent,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LihatBeritaPage(),
                          ),
                        ).then(
                          (_) => _reloadDataAndTimers(),
                        ), // Muat ulang data setelah kembali
                  ),
                  _buildActionCard(
                    title: 'Lakukan Absensi',
                    icon: Icons.how_to_reg_outlined,
                    color: Colors.greenAccent.shade700,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AbsensiForm(),
                          ),
                        ), // Absensi biasanya tidak mengubah data yang ditampilkan di home
                  ),
                  _buildActionCard(
                    title: 'Lihat Agenda',
                    icon: Icons.calendar_today_outlined,
                    color: Colors.blueAccent,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LihatAgendaPage(),
                          ),
                        ).then(
                          (_) => _reloadDataAndTimers(),
                        ), // Muat ulang data setelah kembali
                  ),
                  _buildActionCard(
                    title: 'Rekap Absensi',
                    icon: Icons.history_outlined,
                    color: Colors.indigo,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => RekapPage(isAdmin: _authService.isAdmin),
                          ),
                        ),
                  ),
                  _buildActionCard(
                    // Jika Anda menambahkan ini sebelumnya
                    title: 'Lihat Notulensi Rapat',
                    icon: Icons.notes_outlined,
                    color: Colors.purpleAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotulensiPage(),
                        ),
                      ).then(
                        (_) => _reloadDataAndTimers(),
                      ); // Muat ulang data jika notulensi bisa berubah
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildAgendaCarousel(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
