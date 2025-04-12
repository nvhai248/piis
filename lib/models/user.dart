import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime? updatedAt;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.updatedAt,
    required this.createdAt,
  });

  factory UserProfile.fromUser(User user) {
    final metadata = user.userMetadata;
    return UserProfile(
      id: user.id,
      email: user.email ?? '',
      fullName: metadata?['full_name'] ?? '',
      phoneNumber: metadata?['phone_number'],
      avatarUrl: metadata?['avatar_url'],
      updatedAt: user.updatedAt != null ? DateTime.parse(user.updatedAt!) : null,
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      avatarUrl: json['avatar_url'],
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'updated_at': updatedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: DateTime.now(),
      createdAt: createdAt,
    );
  }
} 