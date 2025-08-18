import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/sp_services.dart';
import 'package:frontend/features/auth/pages/respository/auth_local_repository.dart';
import 'package:frontend/features/auth/pages/respository/auth_repository.dart';
import 'package:frontend/models/user_model.dart';

part 'auth_state.dart';

class Auth extends Cubit<AuthState> {
  Auth() : super(AuthInital());
  final SpServices spServices = SpServices();
  final AuthLocalRepository authLocalRepository = AuthLocalRepository();
  void getUserData() async {
    try {
      emit(AuthLoading());
      UserModel user = await AuthRepository().getUserData();
      emit(AuthLoading());
      if (user.name.isNotEmpty) {
        await authLocalRepository.insertUser(user);
        debugPrint("User data saved locally: ${user.toMap()}");
        emit(AuthUserLoggedIn(user: user));
      } else {
        emit(AuthError(message: "No user data found"));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
      // Handle error, e.g., show a message to the user
    }
  }

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      final UserModel user = await AuthRepository().signUp(
        name: name,
        email: email,
        password: password,
      );
      if (user.name.isNotEmpty) {
        await spServices.getToken();
      }
      // After successful sign up, you might want to log in the user automatically
      emit(AuthUserLoggedIn(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      // Handle error, e.g., show a message to the user
    }
  }

  void login({required String email, required String password}) async {
    try {
      emit(AuthLoading());
      UserModel user = await AuthRepository().login(
        email: email,
        password: password,
      );
      // Save the token from the actual user object
      if (user.name.isNotEmpty) {
        await spServices.getToken();
      }
      await authLocalRepository.insertUser(user);
      emit(AuthUserLoggedIn(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      // Handle error, e.g., show a message to the user
    }
  }

  void logout() async {
    try {
      emit(AuthLoading());
      await spServices.clearToken();
      emit(AuthUserLoggedOut(message: "User logged out successfully"));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      // Handle error, e.g., show a message to the user
    }
  }
}
