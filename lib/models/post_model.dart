class PostModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final String? tanggal;

  // Tambahkan field imageUrl untuk menyimpan path gambar
  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    this.tanggal,
  });
}
