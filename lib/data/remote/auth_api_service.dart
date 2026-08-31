import '../../core/constants/api_constants.dart';
import '../local/entities/user_entity.dart';
import 'dio_client.dart';

class AuthApiService {
  final DioClient _dioClient;

  AuthApiService(this._dioClient);

  /// Login ke backend, return user data jika sukses
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dioClient.post(
        '${ApiConstants.auth}/login',
        data: {'username': username, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Get all users (admin only)
  Future<List<Map<String, dynamic>>> getUsers({String? role}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (role != null) queryParams['role'] = role;

      final response = await _dioClient.get(
        ApiConstants.users,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Create user (admin only)
  Future<Map<String, dynamic>> createUser({
    required String username,
    required String password,
    required String name,
    required String role,
    bool isActive = true,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.users,
        data: {
          'username': username,
          'password': password,
          'name': name,
          'role': role,
          'is_active': isActive,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Update user
  Future<Map<String, dynamic>> updateUser({
    required String id,
    required String name,
    required String role,
    required bool isActive,
  }) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.users}/$id',
        data: {'name': name, 'role': role, 'is_active': isActive},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _dioClient.post(
        '${ApiConstants.users}/$userId/change-password',
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  /// Delete user (soft delete)
  Future<void> deleteUser(String id) async {
    try {
      await _dioClient.delete('${ApiConstants.users}/$id');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Helper: map backend JSON to UserEntity
  static UserEntity mapToUserEntity(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'kasir';
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.kasir,
    );

    return UserEntity(
      id: json['id'] as String,
      username: json['username'] as String,
      password: '', // never expose password from backend
      name: json['name'] as String,
      role: role,
      isActive: json['is_active'] as bool? ?? true,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
