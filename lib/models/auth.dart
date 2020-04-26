import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _tokenExpiry;
  String _userId;
  Timer _authTimer;

  String get token {
    if (_token != null &&
        _tokenExpiry != null &&
        _tokenExpiry.isAfter(DateTime.now())) return _token;
    return null;
  }

  String get userId {
    return _userId;
  }

  bool get isAuthenticated {
    print('-->> isAuthenticated check ${token != null}');
    return token != null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final fullUrl =
        '$authUrl:$urlSegment?key=${env == 'dev' ? devAuthKey : prodAuthKey}';
    print('performing ($urlSegment) action on: $fullUrl');

    try {
      final response = await http.post(
        fullUrl,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final body = json.decode(response.body);
      if (body['error'] != null) {
        throw (body['error']['message']);
      }
      _token = body['idToken'];
      _userId = body['localId'];
      _tokenExpiry = DateTime.now().add(
        Duration(
          seconds: int.parse(body['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'authData',
        json.encode({
          'token': _token,
          'userId': _userId,
          'expiryDate': _tokenExpiry.toIso8601String(),
        }),
      );
    } catch (err) {
      throw HttpException(err);
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authData')) return false;

    final authData = json.decode(prefs.getString('authData'));
    final expiry = DateTime.parse(authData['expiryDate']);
    if (expiry.isBefore(DateTime.now())) return false;

    _token = authData['token'];
    _userId = authData['userId'];
    _tokenExpiry = expiry;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    print('attempting to logout');
    _token = null;
    _tokenExpiry = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final _expiryDiffSeconds =
        _tokenExpiry.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: _expiryDiffSeconds), logout);
  }
}
