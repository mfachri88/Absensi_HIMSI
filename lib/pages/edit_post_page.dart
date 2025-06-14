import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/data_service.dart';
import '../models/post_model.dart';

class EditPostPage extends StatefulWidget {
  final PostModel post;
  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data post yang akan diedit
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    _selectedCategory = widget.post.category;
    _currentImageUrl = widget.post.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Fungsi untuk memilih gambar dari galeri
  /// Menggunakan ImagePicker untuk memilih gambar dan menyimpannya dalam _selectedImage
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  /// Fungsi untuk menghapus gambar yang dipilih
  /// Reset _selectedImage dan _currentImageUrl untuk menghapus gambar
  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _currentImageUrl = null;
    });
  }

  /// Fungsi untuk menyimpan perubahan post
  /// Memvalidasi form, update data di DataService, dan kembali ke halaman sebelumnya
  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Tentukan URL gambar yang akan disimpan
    String? imageUrl;
    if (_selectedImage != null) {
      // Jika ada gambar baru yang dipilih, gunakan path file tersebut
      imageUrl = _selectedImage!.path;
    } else if (_currentImageUrl != null) {
      // Jika tidak ada gambar baru, gunakan gambar lama
      imageUrl = _currentImageUrl;
    }

    // Buat PostModel baru dengan data yang telah diupdate
    final updatedPost = PostModel(
      id: widget.post.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
      imageUrl: imageUrl,
      tanggal: widget.post.tanggal, // Pertahankan tanggal asli
    );

    // Update post di DataService
    final index = DataService.posts.indexWhere((p) => p.id == widget.post.id);
    if (index != -1) {
      DataService.posts[index] = updatedPost;
    }

    // Tampilkan pesan sukses dan kembali ke halaman sebelumnya
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedCategory} berhasil diperbarui!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(
      context,
    ).pop(true); // Return true untuk menandakan ada perubahan
  }

  /// Widget untuk menampilkan preview gambar
  /// Menampilkan gambar dari berbagai sumber (asset, network, file lokal)
  Widget _buildImagePreview() {
    // Prioritas: gambar baru yang dipilih > gambar lama > placeholder
    if (_selectedImage != null) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.broken_image, size: 50)),
          ),
        ),
      );
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImageFromUrl(_currentImageUrl!),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade100,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              SizedBox(height: 8),
              Text('Tidak ada gambar', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
  }

  /// Widget helper untuk membangun gambar dari URL
  /// Menangani berbagai jenis URL (asset, network, file lokal)
  Widget _buildImageFromUrl(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image, size: 50)),
      );
    } else if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder:
            (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image, size: 50)),
      );
    } else {
      final file = File(url);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.broken_image, size: 50)),
        );
      } else {
        return const Center(child: Icon(Icons.broken_image, size: 50));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.post.category}'),
        backgroundColor: Colors.blue,
        actions: [
          // Tombol simpan di AppBar untuk akses mudah
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              'SIMPAN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown untuk memilih kategori
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items:
                    ['Berita', 'Agenda'].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Input field untuk judul
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Input field untuk konten
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Konten',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.article),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Konten tidak boleh kosong';
                  }
                  return null;
                },
                maxLines: 10,
                minLines: 5,
              ),

              const SizedBox(height: 16),

              // Section untuk manajemen gambar
              const Text(
                'Gambar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Preview gambar
              _buildImagePreview(),

              const SizedBox(height: 12),

              // Tombol-tombol untuk manajemen gambar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Pilih Gambar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol hapus gambar hanya muncul jika ada gambar
                  if (_selectedImage != null || _currentImageUrl != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _removeImage,
                        icon: const Icon(Icons.delete),
                        label: const Text('Hapus Gambar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Tombol simpan di bagian bawah
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'SIMPAN PERUBAHAN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
