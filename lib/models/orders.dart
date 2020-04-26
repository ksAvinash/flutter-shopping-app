import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'dart:convert';

import 'cart.dart';

class OrderItem {
  final String id;
  final double price;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.price,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String authToken;
  String userId;
  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartItems, double total) async {
    final timestamp = DateTime.now();

    try {
      final response = await http.post(
        '$api/orders/$userId.json?auth=$authToken',
        body: json.encode(
          {
            'price': total,
            'dateTime': timestamp.toIso8601String(),
            'products': cartItems.map((item) => item.objectMap).toList(),
          },
        ),
      );
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['id'],
          price: total,
          dateTime: timestamp,
          products: cartItems,
        ),
      );
      notifyListeners();
    } catch (err) {
      print(err);
      // throw err;
    }
  }

  Future<void> fetchAndSetOrders() async {
    try {
      final response = await http.get('$api/orders/$userId.json?auth=$authToken');
      final body = json.decode(response.body) as Map<String, dynamic>;
      print(body);
      if (body == null) return;
      List<OrderItem> temp = [];
      print(body);

      
      body.forEach((productId, orderData) {
        temp.add(OrderItem(
          id: orderData['id'],
          price: orderData['price'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>).map((item) {
            print('cart item: $item');
            return CartItem(
              id: item['id'],
              price: item['price'],
              quantity: item['quantity'],
              title: item['title'],
            );
          }).toList(),
        ));
        print('total orders found: ${temp.length}');
        _orders = temp.reversed.toList();
        notifyListeners();
      });
    } catch (err) {
      print('error fetching orders');
      print(err);
      throw err;
    }
  }
}
