import 'package:flutter/material.dart';
import '../models/data_service.dart';
import '../models/post_model.dart';
import '../services/auth_service.dart';
import 'package:uuid/uuid.dart';

class NotulensiPage extends StatefulWidget {
  const NotulensiPage({super.key});

  @override
  State<NotulensiPage> createState() => _NotulensiPageState();
}

class _NotulensiPageState extends State<NotulensiPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tanggalController = TextEditingController(text: _getTodayDate());
  final _searchController = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _searchQuery = '';
  // Helper untuk mendapatkan tanggal hari ini dalam format dd/MM/yyyy
  static String _getTodayDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  /// Fungsi untuk edit notulensi menggunakan BottomSheet yang lebih stabil
  Future<void> _editNotulensiSafe(PostModel notulensi) async {
    // Deklarasi controller di dalam scope lokal
    String title = notulensi.title;
    String content = notulensi.content;
    String tanggal = notulensi.tanggal ?? '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final formKey = GlobalKey<FormState>();

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Edit Notulensi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Form fields
                      TextFormField(
                        initialValue: tanggal,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Rapat (dd/MM/yyyy)',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                          hintText: 'Contoh: 01/06/2025',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tanggal rapat harus diisi';
                          }
                          if (!_isValidDateFormat(value)) {
                            return 'Format tanggal harus dd/MM/yyyy';
                          }
                          return null;
                        },
                        onChanged: (value) => tanggal = value,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        initialValue: title,
                        decoration: const InputDecoration(
                          labelText: 'Judul Rapat',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                          hintText: 'Contoh: Rapat Koordinasi Tim IT',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Judul rapat harus diisi';
                          }
                          return null;
                        },
                        onChanged: (value) => title = value,
                        maxLines: 2,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        initialValue: content,
                        decoration: const InputDecoration(
                          labelText: 'Isi Notulensi',
                          prefixIcon: Icon(Icons.note),
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                          hintText:
                              'Tuliskan hasil rapat, keputusan, dan rencana tindak lanjut',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Isi notulensi harus diisi';
                          }
                          return null;
                        },
                        onChanged: (value) => content = value,
                        minLines: 5,
                        maxLines: 8,
                      ),

                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('BATAL'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  // Update notulensi
                                  final updatedNotulensi = PostModel(
                                    id: notulensi.id,
                                    title: title.trim(),
                                    content: content.trim(),
                                    category: 'Notulensi',
                                    tanggal: tanggal.trim(),
                                    imageUrl: notulensi.imageUrl,
                                  );

                                  // Update di DataService
                                  final index = DataService.posts.indexWhere(
                                    (p) => p.id == notulensi.id,
                                  );
                                  if (index != -1) {
                                    DataService.posts[index] = updatedNotulensi;
                                  }

                                  Navigator.of(context).pop();

                                  // Update state dan tampilkan snackbar
                                  if (mounted) {
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Notulensi berhasil diperbarui!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('SIMPAN'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tanggalController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk memfilter notulensi berdasarkan query pencarian
  List<PostModel> _filterNotulensi(List<PostModel> notulensiList) {
    if (_searchQuery.isEmpty) {
      return notulensiList;
    }
    
    return notulensiList.where((notulensi) {
      final titleLower = notulensi.title.toLowerCase();
      final contentLower = notulensi.content.toLowerCase();
      final tanggalLower = (notulensi.tanggal ?? '').toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      
      return titleLower.contains(queryLower) ||
             contentLower.contains(queryLower) ||
             tanggalLower.contains(queryLower);
    }).toList();
  }

  // Method untuk update search query
  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Metode untuk memvalidasi format tanggal
  bool _isValidDateFormat(String date) {
    // Regex untuk format dd/MM/yyyy
    RegExp dateRegex = RegExp(
      r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$',
    );
    return dateRegex.hasMatch(date);
  }

  void _saveNotulensi() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newNotulensi = PostModel(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: 'Notulensi',
      tanggal: _tanggalController.text.trim(),
    ); // Tambahkan ke DataService
    DataService.posts.add(newNotulensi);

    // Reset form
    _titleController.clear();
    _contentController.clear();
    _tanggalController.text = _getTodayDate();

    // Update state dan tampilkan snackbar hanya jika widget masih mounted
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notulensi berhasil disimpan')),
      );
    }
  }

  // Helper method untuk membangun tampilan detail notulensi
  Widget _buildNotulensiDetail(PostModel post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  post.tanggal ?? 'Tanggal tidak tersedia',
                  style: TextStyle(color: Colors.blue[700], fontSize: 14),
                ),
                const Spacer(),
                // Tombol edit dan hapus untuk admin
                if (_authService.isAdmin) ...[
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue[600], size: 20),
                    onPressed: () => _editNotulensiSafe(post),
                    tooltip: 'Edit notulensi',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[400], size: 20),
                    onPressed: () => _confirmDelete(post),
                    tooltip: 'Hapus notulensi',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(post.content, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  // Metode untuk konfirmasi penghapusan
  Future<void> _confirmDelete(PostModel post) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text(
            "Apakah Anda yakin ingin menghapus notulensi ini?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("BATAL"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("HAPUS"),
            ),
          ],
        );
      },
    );
    if (result == true) {
      // Hapus dari DataService
      DataService.posts.removeWhere((p) => p.id == post.id);

      // Update state dan tampilkan snackbar hanya jika widget masih mounted
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notulensi telah dihapus')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final notulensiList =
        DataService.posts.where((p) => p.category == 'Notulensi').toList();
    final filteredNotulensiList = _filterNotulensi(notulensiList);
    final isAdmin = _authService.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notulensi Rapat'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari notulensi berdasarkan judul, isi, atau tanggal...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _updateSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _updateSearchQuery,
            ),
          ),
          
          // Content Area
          Expanded(
            child: filteredNotulensiList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty ? Icons.search_off : Icons.notes_rounded,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty 
                              ? 'Tidak ada notulensi yang ditemukan'
                              : 'Belum ada notulensi',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        if (_searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Coba gunakan kata kunci lain',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                          ),
                        if (isAdmin && _searchQuery.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: ElevatedButton.icon(
                              onPressed: () => _showCreateNotulensiDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Buat Notulensi'),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: filteredNotulensiList.length,
                    itemBuilder: (context, index) {
                      final post = filteredNotulensiList[index];
                      return _buildNotulensiDetail(post);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showCreateNotulensiDialog(context),
              tooltip: 'Buat Notulensi',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showCreateNotulensiDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Buat Notulensi Rapat'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _tanggalController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Rapat (dd/MM/yyyy)',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      hintText: 'Contoh: 01/06/2025',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tanggal rapat harus diisi';
                      }
                      if (!_isValidDateFormat(value)) {
                        return 'Format tanggal harus dd/MM/yyyy';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Rapat',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                      hintText: 'Contoh: Rapat Koordinasi Tim IT',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul rapat harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Isi Notulensi',
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      hintText:
                          'Tuliskan hasil rapat, keputusan, dan rencana tindak lanjut',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Isi notulensi harus diisi';
                      }
                      return null;
                    },
                    minLines: 5,
                    maxLines: 10,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('BATAL'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop(); // Tutup dialog terlebih dahulu
                  _saveNotulensi(); // Simpan notulensi setelah dialog ditutup
                }
              },
              child: const Text('SIMPAN'),
            ),
          ],
        );
      },
    );
  }
}
