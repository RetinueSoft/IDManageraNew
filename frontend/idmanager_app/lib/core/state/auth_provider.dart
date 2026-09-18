import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';
import '../models/user.dart';
import '../network/api_client.dart';
import 'providers.dart';

const _tokenKey = 'auth_token';
const _userKey = 'auth_user';

class AuthState {
  final UserDto? user;
  final bool isLoading;
  final bool isRestoring;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.isRestoring = true, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({UserDto? user, bool? isLoading, bool? isRestoring, String? error, bool clearError = false}) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        isRestoring: isRestoring ?? this.isRestoring,
        error: clearError ? null : (error ?? this.error),
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthState()) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (token != null && userJson != null) {
      _ref.read(apiClientProvider).setToken(token);
      state = state.copyWith(
        user: UserDto.fromJson(jsonDecode(userJson) as Map<String, dynamic>),
        isRestoring: false,
      );
    } else {
      state = state.copyWith(isRestoring: false);
    }
  }

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = _ref.read(authApiProvider);
      final response = await api.login(phone, password);
      _ref.read(apiClientProvider).setToken(response.accessToken);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, response.accessToken);
      await prefs.setString(_userKey, jsonEncode(response.user.toJson()));

      state = state.copyWith(user: response.user, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> logout() async {
    _ref.read(apiClientProvider).setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    state = const AuthState(isRestoring: false);
  }

  bool hasRole(List<UserRole> roles) => state.user != null && roles.contains(state.user!.role);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));
