import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/domain/user_model.dart';
import 'package:my_project/data/local_user_repository.dart';

abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  ProfileLoaded(this.user);
}

class ProfileUpdated extends ProfileLoaded {
  ProfileUpdated(super.user);
}

class ProfileLoggedOut extends ProfileState {}

class ProfileCubit extends Cubit<ProfileState> {
  final LocalUserRepository _repository;

  ProfileCubit(this._repository) : super(ProfileLoading());

  Future<void> loadUser() async {
    final user = await _repository.getCurrentUser();
    if (user != null) {
      emit(ProfileLoaded(user));
    }
  }

  Future<void> updateUser(String name, String email, String password) async {
    final updatedUser = UserModel(name: name, email: email, password: password);
    await _repository.updateUser(updatedUser);
    emit(ProfileUpdated(updatedUser));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    emit(ProfileLoggedOut());
  }

  Future<void> deleteAccount() async {
    await _repository.deleteUser();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    emit(ProfileLoggedOut());
  }
}
