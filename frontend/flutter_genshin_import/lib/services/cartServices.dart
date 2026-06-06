import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'apiServices.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _loading = false;
  String? _error;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;
  int get itemCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.quantity * item.weapon.price);
  bool get isEmpty => _items.isEmpty;

  Future<void> loadCart() async {
    _setLoading(true);
    try {
      final data = await ApiService.getCartItems();
      _items
        ..clear()
        ..addAll(data);
      _error = null;
    } catch (err) {
      _error = err is ApiException ? err.message : 'Unable to load cart.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart(Weapon weapon, int quantity) async {
    _setLoading(true);
    try {
      final item = await ApiService.addCartItem(weapon.id, quantity);
      final index = _items.indexWhere((element) => element.id == item.id);
      if (index >= 0) {
        _items[index] = item;
      } else {
        _items.add(item);
      }
      _error = null;
    } catch (err) {
      _error = err is ApiException ? err.message : 'Unable to add to cart.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    _setLoading(true);
    try {
      final item = await ApiService.updateCartItem(cartItemId, quantity);
      final index = _items.indexWhere((element) => element.id == item.id);
      if (index >= 0) {
        _items[index] = item;
      }
      _error = null;
    } catch (err) {
      _error = err is ApiException
          ? err.message
          : 'Unable to update cart item.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeItem(int cartItemId) async {
    _setLoading(true);
    try {
      await ApiService.deleteCartItem(cartItemId);
      _items.removeWhere((item) => item.id == cartItemId);
      _error = null;
    } catch (err) {
      _error = err is ApiException
          ? err.message
          : 'Unable to remove cart item.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkout() async {
    _setLoading(true);
    try {
      await ApiService.checkoutCart();
      _items.clear();
      _error = null;
    } catch (err) {
      _error = err is ApiException ? err.message : 'Unable to checkout.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
