import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env.dart';

class ApiClient {
  final String base = Env.baseUrl;

  Future<Map<String, String>> _headers({bool withAuth = false}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _u(String path) => Uri.parse('$base$path');

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body, {bool auth = false}) async {
    final res = await http.post(_u(path), headers: await _headers(withAuth: auth), body: jsonEncode(body));
    final data = res.body.isEmpty ? {} : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return data as Map<String, dynamic>;
    throw ApiError(status: res.statusCode, data: data);
  }

  Future<Map<String, dynamic>> getJson(String path, {bool auth = false}) async {
    final res = await http.get(_u(path), headers: await _headers(withAuth: auth));
    final data = res.body.isEmpty ? {} : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return data as Map<String, dynamic>;
    throw ApiError(status: res.statusCode, data: data);
  }

  Future<List<dynamic>> getList(String path, {bool auth = false}) async {
    final res = await http.get(_u(path), headers: await _headers(withAuth: auth));
    final data = res.body.isEmpty ? [] : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (data is List) return data;
      if (data is Map && data['results'] is List) return List<dynamic>.from(data['results']);
      if (data is Map && data['items'] is List) return List<dynamic>.from(data['items']);
      throw ApiError(status: 200, data: {'detail': 'Unexpected list shape', 'body': data});
    }
    throw ApiError(status: res.statusCode, data: data);
  }
}

class ApiError implements Exception {
  final int status;
  final dynamic data;
  ApiError({required this.status, required this.data});
  @override
  String toString() => 'ApiError($status): $data';
}
