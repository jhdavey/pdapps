import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final int id; 
  final String displayName;
  final String email;
  final bool isEmailVerified; // Email verification status HARD CODED FOR DEV

  // Constructor to initialize AuthUser properties
  const AuthUser({
    required this.id,
    required this.displayName,
    required this.email,
    this.isEmailVerified = true,
  });

  // Factory constructor to create AuthUser from a Map (e.g., from SQLite)
  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      id: map['id'] as int,
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      isEmailVerified: map['isEmailVerified'] as bool,
    );
  }

  // Convert AuthUser to a Map for storage (e.g., in SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'isEmailVerified': isEmailVerified,
    };
  }
}
