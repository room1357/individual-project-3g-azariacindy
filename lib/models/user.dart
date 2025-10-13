class AppUser {
  final String username;
  final String email;
  final String password;

  AppUser({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'password': password,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      username: json['username'],
      email: json['email'],
      password: json['password'],
    );
  }
}
