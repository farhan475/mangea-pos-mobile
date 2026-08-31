import 'package:hive/hive.dart';

part 'user_entity.g.dart';

@HiveType(typeId: 5)
enum UserRole {
  @HiveField(0)
  admin,
  @HiveField(1)
  kasir,
  @HiveField(2)
  owner,
}

@HiveType(typeId: 6)
class UserEntity extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String password; // In production, this should be hashed

  @HiveField(3)
  String name;

  @HiveField(4)
  UserRole role;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? lastLoginAt;

  UserEntity({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'role': role.name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'],
      username: json['username'],
      password: json['password'] ?? '',
      name: json['name'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.kasir,
      ),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
    );
  }

  // Helper methods for role checking
  bool get isAdmin => role == UserRole.admin;
  bool get isKasir => role == UserRole.kasir;
  bool get isOwner => role == UserRole.owner;

  // Permission checks
  bool canAccessPOS() => isAdmin || isKasir;
  bool canAccessOrders() => isAdmin || isKasir;
  bool canAccessTables() => isAdmin || isKasir;
  bool canAccessReports() => isAdmin || isOwner;
  bool canAccessSettings() => isAdmin || isOwner;
  bool canAccessUserManagement() => isAdmin;
  bool canAccessActivityLog() => isAdmin;
  bool canAccessDashboard() => true; // All roles can see dashboard
}
