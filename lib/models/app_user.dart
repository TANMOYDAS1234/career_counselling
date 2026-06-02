/// Authenticated user. Mirrors the web `edubot_user` object
/// ({ email, name, profileImage }).
class AppUser {
  const AppUser({required this.email, this.name, this.profileImage});

  final String email;
  final String? name;
  final String? profileImage;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        email: (json['email'] ?? '') as String,
        name: json['name'] as String?,
        profileImage: json['profileImage'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        if (name != null) 'name': name,
        if (profileImage != null) 'profileImage': profileImage,
      };

  AppUser copyWith({String? name, String? profileImage}) => AppUser(
        email: email,
        name: name ?? this.name,
        profileImage: profileImage ?? this.profileImage,
      );
}
