import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth.dart';
import '../models/user.dart';
import 'api.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<AuthTokens> login(String username, String password) async {
    final json = await _api.postJson('/api/auth/token/', {'username': username, 'password': password});
    final tokens = AuthTokens.fromJson(json);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', tokens.access);
    await prefs.setString('refresh_token', tokens.refresh);
    return tokens;
  }

  Future<AppUser> me() async {
    final json = await _api.getJson('/api/users/me/', auth: true);
    return AppUser.fromJson(json);
  }

  Future<Map<String, dynamic>> register({required String username, required String email, required String firstName, required String lastName, required String password, required String passwordConfirm}) async {
    final json = await _api.postJson('/api/users/register/', {
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'password_confirm': passwordConfirm
    });
    return json;
  }

  Future<Map<String, dynamic>> resetRequest(String email) async {
    return await _api.postJson('/api/users/password/reset/', {'email': email});
  }

  Future<Map<String, dynamic>> resetConfirm({required String uid, required String token, required String newPassword, required String newPasswordConfirm}) async {
    return await _api.postJson('/api/users/password/reset/confirm/', {
      'uid': uid,
      'token': token,
      'new_password': newPassword,
      'new_password_confirm': newPasswordConfirm
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
}
