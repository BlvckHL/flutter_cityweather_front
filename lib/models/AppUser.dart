class AppUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;

  const AppUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? json['sub']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
  };

  String get displayName {
    if ((firstName ?? '').isNotEmpty || (lastName ?? '').isNotEmpty) {
      return [
        firstName,
        lastName,
      ].where((element) => (element ?? '').isNotEmpty).join(' ');
    }
    return email;
  }
}
