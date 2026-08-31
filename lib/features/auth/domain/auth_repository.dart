import '../../../data/local/entities/user_entity.dart';

abstract class AuthRepository {
  /// Login with username and password
  Future<UserEntity?> login(String username, String password);
  
  /// Logout current user
  Future<void> logout();
  
  /// Get current logged in user
  Future<UserEntity?> getCurrentUser();
  
  /// Check if user is logged in
  Future<bool> isLoggedIn();
  
  /// Create new user (admin only)
  Future<UserEntity> createUser({
    required String username,
    required String password,
    required String name,
    required UserRole role,
  });
  
  /// Get all users (admin only)
  Future<List<UserEntity>> getAllUsers();
  
  /// Update user
  Future<void> updateUser(UserEntity user);
  
  /// Delete user (admin only)
  Future<void> deleteUser(String userId);
  
  /// Change password
  Future<void> changePassword(String userId, String newPassword);
}
