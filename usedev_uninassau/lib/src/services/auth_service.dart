import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço Singleton responsável pela autenticação e gerenciamento do token JWT.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _storage = const FlutterSecureStorage();
  String? _token;
  
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  /// Inicializa o serviço verificando se existe um token salvo localmente.
  Future<void> init() async {
    _token = await _storage.read(key: 'jwt_token');
    notifyListeners();
  }

  /// Realiza o login na Fake Store API.
  /// Aceita status 200 ou 201 como sucesso.
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://fakestoreapi.com/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      debugPrint('Resposta do Login: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _token = data['token'];
        // Salva o token de forma segura
        await _storage.write(key: 'jwt_token', value: _token);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erro no Login: $e');
      return false;
    }
  }

  /// Remove o token e desloga o usuário.
  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }
}
