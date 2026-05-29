import 'package:flutter/material.dart';
import '../models/product.dart';

/// Representa um item dentro do carrinho de compras.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

/// Serviço Singleton responsável pelo gerenciamento do carrinho de compras.
class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];
  
  /// Retorna uma lista imutável dos itens no carrinho.
  List<CartItem> get items => List.unmodifiable(_items);

  /// Calcula o valor total do carrinho somando (preço * quantidade) de cada item.
  double get total => _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  /// Adiciona um produto ao carrinho ou incrementa a quantidade se já existir.
  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  /// Remove completamente um produto do carrinho.
  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  /// Atualiza a quantidade de um item. Se chegar a 0, o item é removido.
  void updateQuantity(int productId, int delta) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity += delta;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// Esvazia o carrinho de compras.
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
