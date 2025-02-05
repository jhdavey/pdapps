import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final bool isEmailVerified;

  const AuthUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'].toString(),
      displayName: json['name'],
      email: json['email'],
      isEmailVerified: json['email_verified_at'] != null,
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'isEmailVerified': isEmailVerified,
    };
  }

  @override
  List<Object?> get props => [id, displayName, email, isEmailVerified];
}
