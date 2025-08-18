import "dart:convert";
import "package:flutter/material.dart";
import "package:frontend/core/constants/constanats.dart";
import "package:frontend/core/services/sp_services.dart";
import "package:frontend/features/auth/pages/respository/auth_local_repository.dart";
import "package:frontend/models/user_model.dart";
import "package:http/http.dart" as http;

class AuthRepository {
  final spServices = SpServices();
  final AuthLocalRepository authLocalRepository = AuthLocalRepository();
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${constants.apiBaseUrl}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw jsonDecode(response.body)['message'] ?? 'Failed to sign up';
      }
      
      debugPrint("Response body: ${response.body}");
      return UserModel.fromMap(jsonDecode(response.body));
    } catch (e) {
      throw Exception('Error during sign up: $e');
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${constants.apiBaseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint("Response body: ${response.body}");

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)['message'] ?? 'Failed to log in';
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      // Check if response has nested "user"
      final userData = data['user'] ?? data;
      final token = data['token'] ?? '';

      final user = UserModel.fromMap(userData).copyWith(token: token);

      await spServices.setToken(token);
      debugPrint("✅ User token saved: ${token}");

      return user;
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  Future<UserModel> getUserData() async {
    try {
      debugPrint("Getting user data");
      final spServices = SpServices();
      final token = await spServices.getToken();
      debugPrint("Token is $token");
      if (token == null) {
        throw Exception('No token found');
      }
      final res = await http.post(
        Uri.parse('${constants.apiBaseUrl}/auth/tokenIsValid'),
        headers: {'X-auth-token': token, 'Content-Type': 'application/json'},
      );
      if (res.statusCode != 200) {
        throw Exception('Invalid token');
      }
      final userResponse = await http.get(
        Uri.parse('${constants.apiBaseUrl}/auth'),
        headers: {'X-auth-token': token, 'Content-Type': 'application/json'},
      );
      debugPrint("user data is this: ${userResponse.body}");
      if (res.statusCode != 200) {
        throw Exception('Invalid token');
      }
      final userData = UserModel.fromMap(jsonDecode(userResponse.body));
      debugPrint("User data retrieved: $userData");
      return userData;
    } catch (e) {
      final user = await authLocalRepository.getUser();
      if (user != null) {
        debugPrint("Returning local user data: $user");
        return user;
      } else {
        throw Exception('Error getting user data: $e');
      }
    }
  }
}
