import 'package:flutter/material.dart';
import '../models/post_model.dart';
import 'dart:io';

class DetailPostPage extends StatelessWidget {
  final PostModel post;
  const DetailPostPage({super.key, required this.post});

  Widget _buildPostImage(BuildContext context) {
    // Tambahkan BuildContext
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      Widget imageWidget;
      if (post.imageUrl!.startsWith('assets/')) {
        // Gambar dari assets
        imageWidget = Image.asset(
          post.imageUrl!,
          fit: BoxFit.fitWidth,
          width: double.infinity,
          errorBuilder:
              (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
        );
      } else if (post.imageUrl!.startsWith('http')) {
        // Gambar dari network
        imageWidget = Image.network(
          post.imageUrl!,
          fit: BoxFit.fitWidth,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder:
              (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
        );
      } else {
        // Gambar dari file lokal
        final file = File(post.imageUrl!);
        if (file.existsSync()) {
          imageWidget = Image.file(
            file,
            fit: BoxFit.fitWidth,
            width: double.infinity,
            errorBuilder:
                (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
          );
        } else {
          imageWidget = const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hide_image_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Gambar tidak ditemukan',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
      }
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height *
                0.4, // Batasi tinggi gambar
            maxWidth:
                MediaQuery.of(context).size.width * 0.9, // Batasi lebar gambar
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              12.0,
            ), // Tambahkan border radius
            child: imageWidget,
          ),
        ),
      );
    }
    return const SizedBox.shrink(); // Tidak ada gambar atau path tidak valid
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post.title), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kategori: ${post.category}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ), // Warna disesuaikan
            ),
            const SizedBox(height: 20),
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              _buildPostImage(context), // Panggil dengan context
            const SizedBox(height: 20),
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontSize: 16,
              ), // Ukuran dan spasi disesuaikan
            ),
          ],
        ),
      ),
    );
  }
}
