import 'dart:io';
import 'package:flutter/material.dart';
import '../models/data_service.dart';
import '../models/post_model.dart';
import 'detail_post_page.dart';

class LihatBeritaPage extends StatelessWidget {
  const LihatBeritaPage({super.key});
  Widget _buildImage(PostModel post) {
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      if (post.imageUrl!.startsWith('assets/')) {
        // Gambar dari assets
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            post.imageUrl!,
            width: 145,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => const SizedBox(
                  width: 145,
                  height: 80,
                  child: Icon(Icons.broken_image, size: 40),
                ),
          ),
        );
      } else if (post.imageUrl!.startsWith('http')) {
        // Gambar dari network
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            post.imageUrl!,
            width: 145,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => const SizedBox(
                  width: 145,
                  height: 80,
                  child: Icon(Icons.broken_image, size: 40),
                ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                width: 145,
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              );
            },
          ),
        );
      } else {
        // Gambar dari file lokal
        final file = File(post.imageUrl!);
        if (file.existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(
              file,
              width: 145,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => const SizedBox(
                    width: 145,
                    height: 80,
                    child: Icon(Icons.broken_image, size: 40),
                  ),
            ),
          );
        }
      }
    }
    return SizedBox(
      width: 145,
      height: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          color: Colors.grey[200],
          child: const Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final beritaList =
        DataService.posts.where((post) => post.category == "Berita").toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Terkini'),
        backgroundColor: Colors.blue,
      ), // Judul diubah
      body:
          beritaList.isEmpty
              ? const Center(
                child: Text('Tidak ada berita untuk ditampilkan saat ini.'),
              ) // Pesan diubah
              : ListView.builder(
                padding: const EdgeInsets.all(12.0), // Padding disesuaikan
                itemCount: beritaList.length,
                itemBuilder: (context, index) {
                  final berita = beritaList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(
                        12.0,
                      ), // Padding disesuaikan
                      leading: _buildImage(berita),
                      title: Text(
                        berita.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          berita.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPostPage(post: berita),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
