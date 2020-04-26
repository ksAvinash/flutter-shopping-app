import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  Map<String, dynamic> get objectMap {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  Future<void> toggleFavourite(String authToken, String userId) async {
    final bool currFavourite = this.isFavourite;
    this.isFavourite = !currFavourite;
    notifyListeners();

    try {
      final response = await http.put(
          '$api/user-favourites/$userId/$id.json?auth=$authToken',
          body: json.encode(this.isFavourite));
      if (response.statusCode >= 400) throw ('Error marking item as favourite');
    } catch (err) {
      this.isFavourite = currFavourite;
      notifyListeners();
      // throw HttpException(err);
    }
  }
}
