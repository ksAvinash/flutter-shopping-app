import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity,
  });

  Map<String, dynamic> get objectMap {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
    };
  }

}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get itemsMap {
    return {..._items};
  }

  List<CartItem> get itemsList {
    return [..._items.values.toList()];
  }

  int get itemsCount {
    return _items.length;
  }

  double get totalCartPrice {
    var total = 0.0;
    _items.forEach((key, val) {
      total += val.price * val.quantity;
    });
    return total;
  }

  void addToCart(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          quantity: existingItem.quantity + 1,
        ),
      );
      print('item updated to cart total: $totalCartPrice');
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
      print('item added to cart total: $totalCartPrice');
    }
    notifyListeners();
  }

  void removeSingleQuantityFromCartItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId].quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity - 1,
        ),
      );
      notifyListeners();
    } else
      removeCartItem(productId);
  }

  bool isItemInCart(String productId) {
    return _items.containsKey(productId);
  }

  void removeCartItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }
}
