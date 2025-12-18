class UserModel {
  final int id;
  final String nama;
  final String email;
  final String username;
  final String role;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.username,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nama: json['nama'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
    );
  }
}
