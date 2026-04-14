import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/domain/i_user_repository.dart';
import 'package:my_project/domain/user_model.dart';

class LocalUserRepository implements IUserRepository {
  static const String _userKey = 'saved_user';

  @override
  Future<bool> registerUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    return await prefs.setString(_userKey, userJson);
  }

  @override
  Future<UserModel?> loginUser(String email, String password) async {
    final user = await getCurrentUser();
    if (user != null && user.email == email && user.password == password) {
      return user;
    }
    return null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString != null) {
      final Map<String, dynamic> userMap =
          jsonDecode(userString) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  @override
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  @override
  Future<bool> updateUser(UserModel updatedUser) async {
    return await registerUser(updatedUser);
  }
}
