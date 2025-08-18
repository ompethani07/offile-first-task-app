part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthInital extends AuthState {}
final class AuthLoading extends AuthState {}

final class AuthSignUp extends AuthState{}

final class AuthUserLoggedIn extends AuthState {
  final UserModel user;
  AuthUserLoggedIn({required this.user});
}

final class AuthUserLoggedOut extends AuthState {
  final String message;
  AuthUserLoggedOut({required this.message});
}
final class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

