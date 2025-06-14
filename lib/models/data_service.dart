import 'absen_model.dart';
import 'post_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../models/token_model.dart';

class DataService {
  static List<AbsenModel> absensiList = [];
  static List<PostModel> posts = [
    // Dummy Berita Posts
    PostModel(
      id: const Uuid().v4(),
      title: 'Perkembangan Terbaru AI',
      content:
          'Ini adalah konten lengkap untuk berita dummy pertama mengenai perkembangan terbaru dalam teknologi Kecerdasan Buatan (AI) dan dampaknya pada berbagai industri. Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      category: 'Berita',
      imageUrl: 'assets/img/AI-news.jpg', // Path ke asset image
    ),
    PostModel(
      id: const Uuid().v4(),
      title: 'Inovasi di Bidang Energi Terbarukan',
      content:
          'Pembahasan mendalam tentang inovasi terkini di sektor energi terbarukan, termasuk panel surya efisiensi tinggi dan teknologi penyimpanan energi. Sed ut perspiciatis unde omnis iste natus error sit voluptatem.',
      category: 'Berita',
      imageUrl: 'assets/img/renewable-energy.jpg', // Path ke asset image
    ),
    PostModel(
      id: const Uuid().v4(),
      title: 'Dampak Perubahan Iklim Global',
      content:
          'Laporan komprehensif mengenai dampak perubahan iklim global yang semakin terasa dan upaya-upaya mitigasi yang dilakukan di seluruh dunia. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit.',
      category: 'Berita',
      imageUrl: 'assets/img/perubahan-iklim.jpg', // Path ke asset image
    ),
    // Dummy Agenda Posts
    PostModel(
      id: const Uuid().v4(),
      title: 'Rapat Mingguan Tim Proyek',
      content:
          'Agenda untuk rapat mingguan tim proyek XYZ akan dilaksanakan pada hari Senin pukul 10:00. Pembahasan meliputi progres terkini dan rencana selanjutnya. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam.',
      category: 'Agenda',
      imageUrl: 'assets/img/rapat.jpg', // Path ke asset image
    ),
    PostModel(
      id: const Uuid().v4(),
      title: 'Workshop Pengembangan Aplikasi Mobile',
      content:
          'Workshop intensif selama dua hari mengenai pengembangan aplikasi mobile cross-platform menggunakan Flutter. Terbuka untuk umum. Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur.',
      category: 'Agenda',
      imageUrl: 'assets/img/workshop.jpg', // Path ke asset image
    ),
    PostModel(
      id: const Uuid().v4(),
      title: 'Seminar Nasional Teknologi Pendidikan',
      content:
          'Seminar nasional yang akan membahas peran teknologi dalam transformasi pendidikan di era digital. Menghadirkan pembicara ahli. At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores.',
      category: 'Agenda',
      imageUrl: 'assets/img/seminar-nasional.jpg', // Path ke asset image
    ),
  ];

  // Daftar semua token yang ada
  static final List<TokenModel> _tokens = [];

  // Token aktif saat ini (untuk UI admin)
  static String? activeToken;
  static DateTime? tokenExpiredAt;

  // Generate token baru
  static String? generateToken({required int expiredMinutes}) {
    final rnd = Random();
    // Generate token yang lebih user-friendly (6 digit angka)
    final token = List.generate(6, (_) => rnd.nextInt(10)).join();

    // Set waktu kadaluarsa
    final expiryDate = DateTime.now().add(Duration(minutes: expiredMinutes));

    // Simpan token baru
    final newToken = TokenModel(token: token, expiryDate: expiryDate);
    _tokens.add(newToken);

    // Update informasi token aktif untuk UI admin
    activeToken = token;
    tokenExpiredAt = expiryDate;

    return token;
  }

  // Validasi token untuk user tertentu
  static bool isTokenValidForUser(String token, String userId) {
    // Cari token di daftar
    final tokenObj = _tokens.firstWhere(
      (t) => t.token == token,
      orElse:
          () => TokenModel(
            token: '',
            expiryDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
    );

    // Token valid jika belum kadaluarsa dan belum digunakan oleh user
    return tokenObj.isValid && !tokenObj.isUsedByUser(userId);
  }

  // Tandai token sebagai sudah digunakan oleh user tertentu
  static bool markTokenAsUsedByUser(String token, String userId) {
    final tokenIndex = _tokens.indexWhere((t) => t.token == token);
    if (tokenIndex != -1 && _tokens[tokenIndex].isValid) {
      _tokens[tokenIndex].markAsUsedByUser(userId);
      return true;
    }
    return false;
  }

  // Hapus token yang sudah kadaluarsa
  static void cleanupExpiredTokens() {
    final now = DateTime.now();
    _tokens.removeWhere((token) => token.expiryDate.isBefore(now));
  }

  // Informasi token aktif untuk UI admin
  static String getTokenExpireInfo() {
    if (tokenExpiredAt == null) return "Token belum dibuat";
    return "${tokenExpiredAt!.day}/${tokenExpiredAt!.month}/${tokenExpiredAt!.year} ${tokenExpiredAt!.hour}:${tokenExpiredAt!.minute.toString().padLeft(2, '0')}";
  }

  // Cek status token aktif
  static bool get isActiveTokenValid {
    return activeToken != null &&
        tokenExpiredAt != null &&
        DateTime.now().isBefore(tokenExpiredAt!);
  }

  // Mendapatkan jumlah user yang sudah menggunakan token aktif
  static int getActiveTokenUsageCount() {
    if (activeToken == null) return 0;

    final tokenObj = _tokens.firstWhere(
      (t) => t.token == activeToken,
      orElse: () => TokenModel(token: '', expiryDate: DateTime.now()),
    );

    return tokenObj.usedByUserIds.length;
  }
}
