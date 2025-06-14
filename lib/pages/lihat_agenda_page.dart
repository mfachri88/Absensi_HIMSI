import 'dart:io';
import 'package:flutter/material.dart';
import '../models/data_service.dart';
import '../models/post_model.dart';
import './detail_post_page.dart';

class LihatAgendaPage extends StatelessWidget {
  const LihatAgendaPage({super.key});
  Widget _buildImage(PostModel post) {
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      if (post.imageUrl!.startsWith('assets/')) {
        // Gambar dari assets
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            post.imageUrl!,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => const SizedBox(
                  width: 80,
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
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => const SizedBox(
                  width: 80,
                  height: 80,
                  child: Icon(Icons.broken_image, size: 40),
                ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                width: 80,
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
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => const SizedBox(
                    width: 80,
                    height: 80,
                    child: Icon(Icons.broken_image, size: 40),
                  ),
            ),
          );
        }
      }
    }
    return SizedBox(
      width: 80,
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
    final agendaList =
        DataService.posts.where((post) => post.category == "Agenda").toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda Kegiatan'),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          agendaList.isEmpty
              ? const Center(
                child: Text('Tidak ada agenda untuk ditampilkan saat ini.'),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: agendaList.length,
                itemBuilder: (context, index) {
                  final agenda = agendaList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12.0),
                      leading: _buildImage(agenda),
                      title: Text(
                        agenda.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          agenda.content,
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
                            builder: (_) => DetailPostPage(post: agenda),
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
