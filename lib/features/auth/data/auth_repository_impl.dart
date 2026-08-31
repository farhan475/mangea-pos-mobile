import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database/hive_database.dart';
import '../../../data/local/entities/user_entity.dart';
import '../../../data/remote/auth_api_service.dart';
import '../../../data/remote/dio_client.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _currentUserIdKey = 'current_user_id';
  static const String _pepper = 'mangea.local.auth.v1';
  final _uuid = const Uuid();
  final AuthApiService _authApiService = AuthApiService(DioClient());

  /// Local passwords are stored as salted SHA-256 digests, never plaintext.
  /// (The backend independently stores bcrypt hashes; this hash is only for
  /// the offline Hive cache.)
  String _hashPassword(String userId, String password) {
    final bytes = utf8.encode('$_pepper:$userId:$password');
    return sha256.convert(bytes).toString();
  }

  @override
  Future<UserEntity?> login(String username, String password) async {
    // Try backend login first
    try {
      final data = await _authApiService.login(username, password);
      final userJson = data['user'] as Map<String, dynamic>? ?? data;
      final user = AuthApiService.mapToUserEntity(userJson);

      // Persist JWT for authenticated API calls
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await DioClient.storeToken(token);
      }

      // Cache user in Hive for offline use
      final usersBox = HiveDatabase.usersBoxInstance;
      final existing = usersBox.values.where((u) => u.id == user.id);
      if (existing.isEmpty) {
        // Keep an unusable password marker: this user must log in online
        // until a password is set locally.
        user.password = 'oauth-cached:${_uuid.v4()}';
        user.lastLoginAt = DateTime.now();
        await usersBox.put(user.id, user);
      } else {
        final localUser = existing.first;
        localUser.name = user.name;
        localUser.role = user.role;
        localUser.isActive = user.isActive;
        localUser.lastLoginAt = DateTime.now();
        await localUser.save();
      }

      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserIdKey, user.id);
      return user;
    } catch (_) {
      // Fallback: offline login via Hive
      return _loginOffline(username, password);
    }
  }

  Future<UserEntity?> _loginOffline(String username, String password) async {
    final usersBox = HiveDatabase.usersBoxInstance;
    try {
      final user = usersBox.values.firstWhere(
        (u) => u.username == username,
        orElse: () => throw Exception('User not found'),
      );
      final hashed = _hashPassword(user.id, password);
      final matches = user.password == hashed || user.password == password;
      if (!matches) throw Exception('Invalid password');
      if (!user.isActive) throw Exception('User account is deactivated');

      // Migrate legacy plaintext entries to hashed form
      if (user.password != hashed) {
        user.password = hashed;
      }

      user.lastLoginAt = DateTime.now();
      await user.save();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserIdKey, user.id);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await DioClient.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserIdKey);
    if (userId == null) return null;

    final usersBox = HiveDatabase.usersBoxInstance;
    try {
      return usersBox.values.firstWhere((user) => user.id == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  @override
  Future<UserEntity> createUser({
    required String username,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    // Try backend first
    try {
      final data = await _authApiService.createUser(
        username: username,
        password: password,
        name: name,
        role: role.name,
      );
      final user = AuthApiService.mapToUserEntity(data);
      final usersBox = HiveDatabase.usersBoxInstance;
      await usersBox.put(user.id, user);
      return user;
    } catch (_) {
      return _createUserOffline(
        username: username,
        password: password,
        name: name,
        role: role,
      );
    }
  }

  Future<UserEntity> _createUserOffline({
    required String username,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    final usersBox = HiveDatabase.usersBoxInstance;
    final existingUser =
        usersBox.values.where((user) => user.username == username);
    if (existingUser.isNotEmpty) {
      throw Exception('Username already exists');
    }

    final user = UserEntity(
      id: _uuid.v4(),
      username: username,
      password: '',
      name: name,
      role: role,
      isActive: true,
      createdAt: DateTime.now(),
    );
    user.password = _hashPassword(user.id, password);

    await usersBox.put(user.id, user);
    return user;
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      final data = await _authApiService.getUsers();
      return data.map(AuthApiService.mapToUserEntity).toList();
    } catch (_) {
      return HiveDatabase.usersBoxInstance.values.toList();
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      await _authApiService.updateUser(
        id: user.id,
        name: user.name,
        role: user.role.name,
        isActive: user.isActive,
      );
    } catch (_) {}
    final usersBox = HiveDatabase.usersBoxInstance;
    final local = usersBox.values.where((u) => u.id == user.id);
    if (local.isNotEmpty) {
      final u = local.first;
      u.name = user.name;
      u.role = user.role;
      u.isActive = user.isActive;
      await u.save();
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _authApiService.deleteUser(userId);
    } catch (_) {}
    final usersBox = HiveDatabase.usersBoxInstance;
    final local = usersBox.values.where((u) => u.id == userId);
    if (local.isNotEmpty) {
      await local.first.delete();
    }
  }

  @override
  Future<void> changePassword(String userId, String newPassword) async {
    final usersBox = HiveDatabase.usersBoxInstance;
    final user = usersBox.values.firstWhere(
      (u) => u.id == userId,
      orElse: () => throw Exception('User not found'),
    );
    user.password = _hashPassword(user.id, newPassword);
    await user.save();
  }

  /// Initialize default users if none exist
  Future<void> initializeDefaultUsers() async {
    final usersBox = HiveDatabase.usersBoxInstance;
    if (usersBox.isEmpty) {
      await _createUserOffline(
        username: 'admin',
        password: 'admin123',
        name: 'Administrator',
        role: UserRole.admin,
      );
      await _createUserOffline(
        username: 'kasir',
        password: 'kasir123',
        name: 'Kasir 1',
        role: UserRole.kasir,
      );
      await _createUserOffline(
        username: 'owner',
        password: 'owner123',
        name: 'Owner',
        role: UserRole.owner,
      );
    }
  }
}
