import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/apiServices.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  String? _token;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  String? get token => _token;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  // // TODO: Replace with your Web client ID from Google Cloud Console.
  // // Example: const _webClientId = '1234567890-abcdefg.apps.googleusercontent.com';
  // const String _webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  // // Provide the web client ID as `serverClientId` so Android/iOS will
  // // return an ID token usable by the backend for server-side verification.
  // final _googleSignIn = GoogleSignIn(
  //   scopes: ['email', 'profile'],
  //   serverClientId: _webClientId,
  // );

  
  // ── Restore session ──────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');
    final role = prefs.getString('user_role');
    final id = prefs.getInt('user_id');
    if (_token != null && id != null) {
      _user = AppUser(id: id, name: name!, email: email!, role: role!);
    }
    notifyListeners();
  }

  Future<void> _saveSession(String token, AppUser user) async {
    _token = token;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_role', user.role);
    await prefs.setInt('user_id', user.id);
  }

  // ── Login ─────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await ApiService.login(email, password);
      await _saveSession(result.token, result.user);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Connection error. Please check the server.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Register ──────────────────────────────────────────────
  Future<bool> register(String name, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await ApiService.register(name, email, password);
      await _saveSession(result.token, result.user);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Connection error. Please check the server.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Google Sign-In ────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _error = 'Google sign-in cancelled.';
        return false;
      }
      final auth = await googleUser.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('No ID token');

      final result = await ApiService.googleLogin(idToken);
      await _saveSession(result.token, result.user);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Google sign-in failed: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _googleSignIn.signOut();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
