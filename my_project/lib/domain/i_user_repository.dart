import 'package:my_project/domain/user_model.dart';

abstract class IUserRepository {
  Future<bool> registerUser(UserModel user);

  Future<UserModel?> loginUser(String email, String password);

  Future<UserModel?> getCurrentUser();

  Future<void> deleteUser();

  Future<bool> updateUser(UserModel updatedUser);
}
