/// Admin API yanıtlarını/isteklerini temsil eden model; JSON dönüşümleriyle
/// REST uçları arasında köprü kurar.
class Admin {
  final int? id;
  final String username;
  final String email;
  final String? password;
  final String fullName;
  final DateTime? createdAt;

  Admin({
    this.id,
    required this.username,
    required this.email,
    this.password,
    required this.fullName,
    this.createdAt,
  });

  /// Backend'den gelen JSON map'ini Admin nesnesine dönüştürür.
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] as int?,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      fullName: json['full_name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Admin nesnesini API'ye geri göndermek için JSON map'ine çevirir.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

