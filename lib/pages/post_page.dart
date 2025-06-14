import 'dart:io'; // Untuk File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:uuid/uuid.dart';
import '../models/data_service.dart';
import '../models/post_model.dart';
import '../services/auth_service.dart';
import 'edit_post_page.dart';

class PostPage extends StatefulWidget {
  final String category;
  const PostPage({super.key, this.category = 'Berita'});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _selectedCategory = 'Berita';
  File? _selectedImage; // Untuk menyimpan file gambar yang dipilih
  final _authService = AuthService(); // Instance AuthService untuk cek admin

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _savePost() {
    if (_titleCtrl.text.isEmpty || _contentCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul dan Isi Konten tidak boleh kosong!'),
        ),
      );
      return;
    }

    // Untuk saat ini, kita hanya menyimpan path lokal gambar.
    // Dalam aplikasi nyata, Anda akan mengunggah gambar ke server dan menyimpan URL-nya.
    String? imageUrl = _selectedImage?.path;

    DataService.posts.add(
      PostModel(
        id: const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        category: _selectedCategory,
        imageUrl: imageUrl, // Simpan path gambar
      ),
    );

    _titleCtrl.clear();
    _contentCtrl.clear();
    setState(() {
      _selectedImage = null; // Reset gambar yang dipilih
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post berhasil ditambahkan!')));
  }

  // Helper method untuk menampilkan gambar postingan dengan penanganan berbagai sumber
  Widget _buildPostImage(PostModel post) {
    if (post.imageUrl == null || post.imageUrl!.isEmpty) {
      return Icon(
        post.category == "Berita" ? Icons.article : Icons.event,
        size: 40,
        color: Colors.grey,
      );
    }

    if (post.imageUrl!.startsWith('assets/')) {
      // Handle asset images
      return Image.asset(
        post.imageUrl!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Icon(
              post.category == "Berita" ? Icons.article : Icons.event,
              size: 40,
              color: Colors.grey,
            ),
      );
    } else if (post.imageUrl!.startsWith('http')) {
      // Handle network images
      return Image.network(
        post.imageUrl!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Icon(
              post.category == "Berita" ? Icons.article : Icons.event,
              size: 40,
              color: Colors.grey,
            ),
      );
    } else {
      // Handle local file images
      try {
        final file = File(post.imageUrl!);
        if (file.existsSync()) {
          return Image.file(file, width: 50, height: 50, fit: BoxFit.cover);
        }
      } catch (e) {
        // Handle file error silently
      }
      return Icon(
        post.category == "Berita" ? Icons.article : Icons.event,
        size: 40,
        color: Colors.grey,
      );
    }
  }

  /// Fungsi untuk navigasi ke halaman edit post
  /// Hanya admin yang bisa mengakses halaman edit
  /// Setelah edit, refresh halaman untuk menampilkan perubahan
  Future<void> _editPost(PostModel post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPostPage(post: post)),
    );

    // Jika ada perubahan, refresh halaman
    if (result == true) {
      setState(() {
        // setState akan memicu rebuild widget dan memuat data terbaru
      });
    }
  }

  // Metode untuk konfirmasi penghapusan
  Future<void> _confirmDelete(int index, String title) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: Text(
            "Apakah Anda yakin ingin menghapus postingan \"$title\"?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("BATAL"),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("HAPUS"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() {
        DataService.posts.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Post berhasil dihapus!')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.category; // Inisialisasi kategori dari widget jika ada
  }

  @override
  Widget build(BuildContext context) {
    final allPosts = DataService.posts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Postingan'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Tambahkan SingleChildScrollView agar bisa di-scroll
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Judul",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentCtrl,
                decoration: const InputDecoration(
                  labelText: "Isi Konten",
                  border: OutlineInputBorder(),
                  alignLabelWithHint:
                      true, // Agar label tetap di atas saat multi-line
                ),
                maxLines: 5, // Memungkinkan input multi-baris untuk paragraf
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              // Widget untuk memilih gambar
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Image.file(
                    _selectedImage!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ElevatedButton.icon(
                icon: const Icon(Icons.image_search),
                label: Text(
                  _selectedImage == null ? 'Pilih Gambar' : 'Ganti Gambar',
                ),
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items:
                    ['Berita', 'Agenda'].map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Tambah Post'),
                onPressed: _savePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const Divider(height: 30, thickness: 1),
              Text(
                "Daftar Postingan (${allPosts.length})",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              if (allPosts.isEmpty)
                const Center(child: Text("Belum ada postingan.")),
              ListView.builder(
                shrinkWrap: true, // Penting karena ListView di dalam Column
                physics:
                    const NeverScrollableScrollPhysics(), // Nonaktifkan scroll internal ListView
                itemCount: allPosts.length,
                itemBuilder: (context, index) {
                  final post = allPosts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: _buildPostImage(
                        post,
                      ), // Gunakan helper method untuk gambar
                      title: Text(
                        post.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Kategori: ${post.category}"),
                          Text(
                            post.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_authService.isAdmin)
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue[400]),
                              onPressed: () => _editPost(post),
                              tooltip: 'Edit postingan',
                            ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red[400]),
                            onPressed: () => _confirmDelete(index, post.title),
                            tooltip: 'Hapus postingan',
                          ),
                        ],
                      ),
                      isThreeLine:
                          post.imageUrl != null, // Sesuaikan jika ada gambar
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
