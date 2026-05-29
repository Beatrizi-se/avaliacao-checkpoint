import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

/// Serviço responsável por realizar as chamadas à Fake Store API.
class ApiService {
  static const String _baseUrl = 'https://fakestoreapi.com';

  /// Busca a lista de todos os produtos disponíveis.
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar produtos');
      }
    } catch (e) {
      throw Exception('Erro ao buscar produtos: $e');
    }
  }

  /// Busca os detalhes de um produto específico pelo seu ID.
  Future<Product> getProduct(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products/$id'));
      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Falha ao carregar o produto');
      }
    } catch (e) {
      throw Exception('Erro ao buscar o produto: $e');
    }
  }
}
