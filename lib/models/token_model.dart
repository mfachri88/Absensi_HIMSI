class TokenModel {
  final String token;
  final DateTime expiryDate;
  final List<String>
  usedByUserIds; // Menyimpan ID pengguna yang sudah menggunakan token

  TokenModel({
    required this.token,
    required this.expiryDate,
    List<String>? usedByUserIds,
  }) : usedByUserIds = usedByUserIds ?? [];

  // Cek apakah token valid (belum kadaluarsa)
  bool get isValid => DateTime.now().isBefore(expiryDate);

  // Cek apakah token sudah digunakan oleh user tertentu
  bool isUsedByUser(String userId) => usedByUserIds.contains(userId);

  // Tandai token sebagai sudah digunakan oleh user tertentu
  void markAsUsedByUser(String userId) {
    if (!usedByUserIds.contains(userId)) {
      usedByUserIds.add(userId);
    }
  }
}
