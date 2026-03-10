import '../../domain/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phoneNumber,
    required super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  factory UserModel.fromFirebaseUser(
    firebase_auth.User firebaseUser, {
    String? name,
    String? phoneNumber,
  }) {
    return UserModel(
      id: firebaseUser.uid,
      name: name ??
          firebaseUser.displayName ??
          firebaseUser.email?.split('@').first ??
          'User',
      email: firebaseUser.email ?? '',
      phoneNumber: phoneNumber ?? firebaseUser.phoneNumber,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      updatedAt: firebaseUser.metadata.lastSignInTime,
    );
  }
}
