class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final bool twoFactorEnabled;
  final String theme;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.twoFactorEnabled,
    required this.theme,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    phone: json['phone'],
    twoFactorEnabled: json['twoFactorEnabled'] ?? true,
    theme: json['theme'] ?? 'light',
    createdAt: json['createdAt'],
  );

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    bool? twoFactorEnabled,
    String? theme,
  }) => UserModel(
    id: id,
    email: email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phone: phone ?? this.phone,
    twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    theme: theme ?? this.theme,
    createdAt: createdAt,
  );
}
