import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Helpers ────────────────────────────────────────────────
  static Map<String, dynamic> _parseBody(http.Response res) {
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static void _checkStatus(http.Response res) {
    if (res.statusCode >= 400) {
      final body = _parseBody(res);
      throw ApiException(
        body['message'] as String? ?? 'Unknown error',
        res.statusCode,
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  //  AUTH
  // ══════════════════════════════════════════════════════════

  static Future<AuthResult> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    _checkStatus(res);
    final body = _parseBody(res);
    return AuthResult.fromJson(body);
  }

  static Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    _checkStatus(res);
    return AuthResult.fromJson(_parseBody(res));
  }

  static Future<AuthResult> googleLogin(String idToken) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );
    _checkStatus(res);
    return AuthResult.fromJson(_parseBody(res));
  }

  // ══════════════════════════════════════════════════════════
  //  WEAPONS
  // ══════════════════════════════════════════════════════════

  /// GET /api/weapons — public
  static Future<List<Weapon>> getWeapons({
    String search = '',
    String type = '',
  }) async {
    final uri = Uri.parse('$baseUrl/weapons').replace(
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        if (type.isNotEmpty) 'type': type,
      },
    );
    final res = await http.get(uri);
    _checkStatus(res);
    final body = _parseBody(res);
    final List data = body['data'] as List;
    return data.map((e) => Weapon.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/weapons/:id — public
  static Future<Weapon> getWeaponById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/weapons/$id'));
    _checkStatus(res);
    return Weapon.fromJson(_parseBody(res)['data'] as Map<String, dynamic>);
  }

  /// POST /api/weapons — admin
  static Future<Weapon> createWeapon(Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/weapons'),
      headers: headers,
      body: jsonEncode(data),
    );
    _checkStatus(res);
    return Weapon.fromJson(_parseBody(res)['data'] as Map<String, dynamic>);
  }

  /// PUT /api/weapons/:id — admin
  static Future<Weapon> updateWeapon(int id, Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    final res = await http.put(
      Uri.parse('$baseUrl/weapons/$id'),
      headers: headers,
      body: jsonEncode(data),
    );
    _checkStatus(res);
    return Weapon.fromJson(_parseBody(res)['data'] as Map<String, dynamic>);
  }

  /// DELETE /api/weapons/:id — admin
  static Future<void> deleteWeapon(int id) async {
    final headers = await _authHeaders();
    final res = await http.delete(
      Uri.parse('$baseUrl/weapons/$id'),
      headers: headers,
    );
    _checkStatus(res);
  }

  // ══════════════════════════════════════════════════════════
  //  ORDERS
  // ══════════════════════════════════════════════════════════

  /// POST /api/orders — authenticated user
  static Future<Order> placeOrder(int weaponId, int quantity) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: headers,
      body: jsonEncode({'weapon_id': weaponId, 'quantity': quantity}),
    );
    _checkStatus(res);
    return Order.fromJson(_parseBody(res)['data'] as Map<String, dynamic>);
  }

  /// GET /api/orders/my — authenticated user
  static Future<List<Order>> getMyOrders() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/orders/my'),
      headers: headers,
    );
    _checkStatus(res);
    final List data = _parseBody(res)['data'] as List;
    return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }
}

// ── Supporting classes ──────────────────────────────────────

class AuthResult {
  final String token;
  final AppUser user;

  AuthResult({required this.token, required this.user});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String,
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
