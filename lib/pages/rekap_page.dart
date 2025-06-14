import 'package:flutter/material.dart';
import '../models/data_service.dart';
import '../models/absen_model.dart';
import 'package:intl/intl.dart'; // Import untuk format tanggal

class RekapPage extends StatefulWidget {
  final bool isAdmin; // Tambahkan parameter untuk kontrol akses
  const RekapPage({super.key, this.isAdmin = false});

  @override
  State<RekapPage> createState() => _RekapPageState();
}

class _RekapPageState extends State<RekapPage> {
  int currentPage = 0;
  final int perPage = 8; // Menambah jumlah item per halaman
  String searchText = '';
  String selectedKategori = 'Semua';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm'); // Format tanggal
  final dateOnlyFormat = DateFormat('dd/MM/yyyy'); // Format tanggal saja

  // List kategori kegiatan
  final List<String> kategoriList = [
    'Semua',
    'Rapat',
    'Pelatihan',
    'Workshop',
    'Kegiatan Sosial',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan kriteria
    List<AbsenModel> filtered = DataService.absensiList;

    // Filter berdasarkan nama
    if (searchText.isNotEmpty) {
      filtered =
          filtered
              .where(
                (a) => a.nama.toLowerCase().contains(searchText.toLowerCase()),
              )
              .toList();
    }

    // Filter berdasarkan kategori
    if (selectedKategori != 'Semua') {
      filtered =
          filtered
              .where(
                (a) =>
                    a.kegiatan == selectedKategori ||
                    (selectedKategori == 'Lainnya' &&
                        ![
                          'Rapat',
                          'Pelatihan',
                          'Workshop',
                          'Kegiatan Sosial',
                        ].contains(a.kegiatan)),
              )
              .toList();
    }

    // Filter berdasarkan range tanggal
    if (selectedStartDate != null) {
      final startTime = DateTime(
        selectedStartDate!.year,
        selectedStartDate!.month,
        selectedStartDate!.day,
      );
      filtered =
          filtered
              .where(
                (a) =>
                    a.timestamp.isAfter(startTime) ||
                    a.timestamp.isAtSameMomentAs(startTime),
              )
              .toList();
    }

    if (selectedEndDate != null) {
      final endTime = DateTime(
        selectedEndDate!.year,
        selectedEndDate!.month,
        selectedEndDate!.day,
        23,
        59,
        59, // Akhir hari
      );
      filtered =
          filtered
              .where(
                (a) =>
                    a.timestamp.isBefore(endTime) ||
                    a.timestamp.isAtSameMomentAs(endTime),
              )
              .toList();
    }

    // Urutkan berdasarkan tanggal terbaru
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Hitung jumlah halaman dan data saat ini
    final int pages = (filtered.length / perPage).ceil();
    final currentData =
        filtered.skip(currentPage * perPage).take(perPage).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Absensi'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context),
            tooltip: 'Filter Data',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () => setState(() {
                  searchText = '';
                  selectedKategori = 'Semua';
                  selectedStartDate = null;
                  selectedEndDate = null;
                  currentPage = 0;
                }),
            tooltip: 'Reset Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel filter
          _buildFilterPanel(),

          // Tampilkan filter yang aktif
          _buildActiveFiltersChips(),

          // List data
          Expanded(
            child:
                currentData.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 70,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada data absensi ditemukan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (searchText.isNotEmpty ||
                              selectedKategori != 'Semua' ||
                              selectedStartDate != null ||
                              selectedEndDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: TextButton.icon(
                                icon: const Icon(Icons.filter_list_off),
                                label: const Text('Hapus semua filter'),
                                onPressed:
                                    () => setState(() {
                                      searchText = '';
                                      selectedKategori = 'Semua';
                                      selectedStartDate = null;
                                      selectedEndDate = null;
                                      currentPage = 0;
                                    }),
                              ),
                            ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: currentData.length,
                      itemBuilder: (context, index) {
                        final absen = currentData[index];
                        return _buildAbsenCard(absen);
                      },
                    ),
          ),

          // Pagination
          if (filtered.isNotEmpty) _buildPaginationControls(pages),
        ],
      ),
      floatingActionButton:
          widget.isAdmin
              ? FloatingActionButton(
                onPressed: () => _exportData(filtered),
                tooltip: 'Ekspor Data',
                child: const Icon(Icons.download),
              )
              : null,
    );
  }

  Widget _buildFilterPanel() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari berdasarkan nama',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              searchText.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed:
                        () => setState(() {
                          searchText = '';
                        }),
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged:
            (value) => setState(() {
              searchText = value;
              currentPage =
                  0; // Reset ke halaman pertama saat melakukan pencarian
            }),
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    List<Widget> chips = [];

    if (selectedKategori != 'Semua') {
      chips.add(
        _buildFilterChip(
          'Kategori: $selectedKategori',
          () => setState(() {
            selectedKategori = 'Semua';
          }),
        ),
      );
    }

    if (selectedStartDate != null) {
      chips.add(
        _buildFilterChip(
          'Mulai: ${dateOnlyFormat.format(selectedStartDate!)}',
          () => setState(() {
            selectedStartDate = null;
          }),
        ),
      );
    }

    if (selectedEndDate != null) {
      chips.add(
        _buildFilterChip(
          'Sampai: ${dateOnlyFormat.format(selectedEndDate!)}',
          () => setState(() {
            selectedEndDate = null;
          }),
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: chips),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDelete,
        backgroundColor: Colors.blue.shade100,
      ),
    );
  }

  Widget _buildAbsenCard(AbsenModel absen) {
    // Menentukan warna card berdasarkan jenis kegiatan
    Color cardColor;
    IconData activityIcon;

    switch (absen.kegiatan) {
      case 'Rapat':
        cardColor = Colors.blue.shade50;
        activityIcon = Icons.people;
        break;
      case 'Pelatihan':
        cardColor = Colors.green.shade50;
        activityIcon = Icons.school;
        break;
      case 'Workshop':
        cardColor = Colors.orange.shade50;
        activityIcon = Icons.build;
        break;
      case 'Kegiatan Sosial':
        cardColor = Colors.purple.shade50;
        activityIcon = Icons.volunteer_activism;
        break;
      default:
        cardColor = Colors.grey.shade50;
        activityIcon = Icons.event_note;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: ExpansionTile(
        title: Text(
          absen.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(activityIcon, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Text(absen.kegiatan),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Text(dateFormat.format(absen.timestamp)),
              ],
            ),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(activityIcon, color: Colors.white),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hanya menampilkan divisi jika tidak null dan tidak kosong
                if (absen.divisi.isNotEmpty)
                  _buildInfoRow('Divisi', absen.divisi),

                // Hanya menampilkan asal kampus jika tidak null dan tidak kosong
                if (absen.asalKampus.isNotEmpty)
                  _buildInfoRow('Asal Kampus', absen.asalKampus),

                _buildInfoRow('Kegiatan', absen.kegiatan),

                if (absen.kegiatanLain.isNotEmpty)
                  _buildInfoRow('Detail Kegiatan', absen.kegiatanLain),

                _buildInfoRow(
                  'Tanggal & Waktu',
                  dateFormat.format(absen.timestamp),
                ),

                const Divider(height: 24),

                const Text(
                  'Deskripsi Tugas:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    absen.tugas,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),

                // Tombol hapus
                if (widget.isAdmin) ...[
                  const Divider(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text('Hapus Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _confirmDelete(context, absen),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int pages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed:
                currentPage > 0 ? () => setState(() => currentPage--) : null,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 16),
          Text(
            'Halaman ${currentPage + 1} dari ${pages > 0 ? pages : 1}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed:
                currentPage < pages - 1
                    ? () => setState(() => currentPage++)
                    : null,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter Data Absensi',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Kategori Kegiatan
                      const Text(
                        'Kategori Kegiatan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children:
                            kategoriList.map((kategori) {
                              return ChoiceChip(
                                label: Text(kategori),
                                selected: selectedKategori == kategori,
                                onSelected: (selected) {
                                  if (selected) {
                                    setModalState(
                                      () => selectedKategori = kategori,
                                    );
                                    setState(() => selectedKategori = kategori);
                                  }
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Rentang Tanggal
                      const Text(
                        'Rentang Tanggal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tanggal Mulai
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Tanggal Mulai'),
                        subtitle: Text(
                          selectedStartDate != null
                              ? dateOnlyFormat.format(selectedStartDate!)
                              : 'Pilih tanggal mulai',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedStartDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setModalState(() => selectedStartDate = picked);
                            setState(() => selectedStartDate = picked);
                          }
                        },
                      ),

                      // Tanggal Selesai
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Tanggal Selesai'),
                        subtitle: Text(
                          selectedEndDate != null
                              ? dateOnlyFormat.format(selectedEndDate!)
                              : 'Pilih tanggal selesai',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedEndDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setModalState(() => selectedEndDate = picked);
                            setState(() => selectedEndDate = picked);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Tombol Aksi
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  selectedKategori = 'Semua';
                                  selectedStartDate = null;
                                  selectedEndDate = null;
                                });
                                setState(() {
                                  selectedKategori = 'Semua';
                                  selectedStartDate = null;
                                  selectedEndDate = null;
                                  currentPage = 0;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Reset Filter'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() => currentPage = 0);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Terapkan Filter'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  // Fungsi untuk konfirmasi hapus data
  Future<void> _confirmDelete(BuildContext context, AbsenModel absen) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: Text(
            "Apakah Anda yakin ingin menghapus data absensi untuk ${absen.nama}?\n\nTindakan ini tidak dapat dibatalkan.",
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
        DataService.absensiList.removeWhere(
          (item) =>
              item.nama == absen.nama &&
              item.timestamp == absen.timestamp &&
              item.token == absen.token,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data absensi telah dihapus'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Fungsi untuk mengekspor data (placeholder)
  void _exportData(List<AbsenModel> data) {
    // Implementasi ekspor data bisa dilakukan di sini
    // Contoh: ekspor ke CSV, PDF, dll.

    final snackBar = SnackBar(
      content: Text('Mengekspor ${data.length} data absensi...'),
      action: SnackBarAction(
        label: 'BATAL',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Fungsi ekspor yang sebenarnya akan ditambahkan di sini
  }
}
