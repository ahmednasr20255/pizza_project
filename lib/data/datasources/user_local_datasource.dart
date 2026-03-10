import '../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<UserModel?> getUser(String id);
  Future<List<UserModel>> getAllUsers();
  Future<void> cacheUser(UserModel user);
  Future<void> cacheUsers(List<UserModel> users);
  Future<void> deleteUser(String id);
  Future<void> clearCache();
}
