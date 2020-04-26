import 'product.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'http_exception.dart';
import '../config.dart';

class AllProducts with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
  ];
  String authToken;
  String userId;
  AllProducts(this.authToken, this.userId, this._items);


  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouritesOnlyItems {
    return _items.where((prod) => prod.isFavourite).toList();
  }

  Product getProductById(String productId) {
    return _items.firstWhere((item) => item.id == productId);
  }

  Future<void> addProduct(Product p) async {
    try {
      final pMap = p.objectMap;
      pMap['creatorId'] = userId;

      final response =
          await http.post('$api/products.json?auth=$authToken', body: json.encode(pMap));
      final body = json.decode(response.body);
      print('http::  add product request was successful $body');
      final product = Product(
        id: body['id'],
        title: p.title,
        description: p.description,
        price: p.price,
        imageUrl: p.imageUrl,
      );
      _items.add(product);
      notifyListeners();
    } catch (err) {
      print('http:: add product request failed');
      throw HttpException('Adding product failed');
    }
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    try {
      var url = '$api/products.json?auth=$authToken';
      if (filterByUser) url += '&orderBy="creatorId"&equalTo="$userId"';
      print('-->> fetch products url: $url');

      final response = await http.get(url);
      final body = json.decode(response.body) as Map<String, dynamic>;
      List<Product> temp = [];
      if (body == null) return;
      print(body);


      final favResponse = await http.get('$api/user-favourites/$userId.json?auth=$authToken');
      print(json.decode(favResponse.body));
      final favBody = json.decode(favResponse.body);
      print('user favourites $favBody');

      body.forEach((productId, val) {
        print('http:: fetching product found id: $productId');
        temp.add(
          Product(
            id: productId,
            title: val['title'],
            description: val['description'],
            imageUrl: val['imageUrl'],
            price: val['price'],
            isFavourite: (favBody == null || favBody[productId] == null) ? false : favBody[productId],
          ),
        );
      });
      _items = temp;
      notifyListeners();
    } catch (err) {
      print(err);
      print('http:: error fetching products');
    }
  }

  bool isProductItemPresent(String productId) {
    return _items.indexWhere((item) => item.id == productId) != -1;
  }

  Future<void> deleteProductById(String productId) async {
    int index = _items.indexWhere((item) => item.id == productId);
    if (index < 0) return;

    Product item = _items[index];
    _items.removeAt(index);
    notifyListeners();

    try {
      final response = await http.delete('$api/products/$productId.json?auth=$authToken');
      if (response.statusCode >= 400) {
        throw('Deleting product failed!');
      }
      item = null;
    } catch (err) {
      print('http:: deleting product failed $productId');
      _items.insert(index, item);
      notifyListeners();
      throw HttpException(err);
    }
  }

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((item) => item.id == product.id);
    if (index < 0) return;

    print('http:: updating product ${product.id}');
    final response = await http.patch('$api/products/${product.id}.json?auth=$authToken',
        body: json.encode(product.objectMap));
    if (response.statusCode >= 400) {
      throw HttpException('Updating product failed');
    }
    _items.removeAt(index);
    _items.insert(index, product);
    notifyListeners();
  }
}
