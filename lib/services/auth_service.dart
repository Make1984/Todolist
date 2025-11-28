import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  // In-memory storage for demo purposes
  final Map<String, Map<String, String>> _users =
      {}; // email -> {password, name, id}
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Load saved data
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load users
    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      final Map<String, dynamic> usersMap = json.decode(usersJson);
      _users.clear();
      usersMap.forEach((email, userData) {
        _users[email] = Map<String, String>.from(userData);
      });
    }

    // Load current user
    final currentUserId = prefs.getString('currentUserId');
    if (currentUserId != null) {
      final currentUserJson = prefs.getString('currentUser');
      if (currentUserJson != null) {
        _currentUser = User.fromJson(json.decode(currentUserJson));
        notifyListeners();
      }
    }
  }

  // Save users to storage
  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('users', json.encode(_users));
  }

  // Save current user to storage
  Future<void> _saveCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString('currentUserId', _currentUser!.id);
      await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
    } else {
      await prefs.remove('currentUserId');
      await prefs.remove('currentUser');
    }
  }

  // Sign up new user
  Future<bool> signUp({
    required String email,
    required String name,
    required String password,
  }) async {
    // Check if user already exists
    if (_users.containsKey(email)) {
      return false;
    }

    // Create new user
    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    _users[email] = {'password': password, 'name': name, 'id': userId};

    // Save users
    await _saveUsers();

    // Auto login after signup
    _currentUser = User(
      id: userId,
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );

    await _saveCurrentUser();
    notifyListeners();
    return true;
  }

  // Login existing user
  Future<bool> login({required String email, required String password}) async {
    // Check if user exists and password matches
    if (!_users.containsKey(email)) {
      return false;
    }

    final userData = _users[email]!;
    if (userData['password'] != password) {
      return false;
    }

    // Set current user
    _currentUser = User(
      id: userData['id']!,
      email: email,
      name: userData['name']!,
      createdAt: DateTime.now(),
    );

    await _saveCurrentUser();
    notifyListeners();
    return true;
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    await _saveCurrentUser();
    notifyListeners();
  }
}
