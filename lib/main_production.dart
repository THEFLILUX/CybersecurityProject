import 'package:chat_frontend/app/app.dart';
import 'package:chat_frontend/bootstrap.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  bootstrap(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final preferences = await SharedPreferences.getInstance();
    final httpClient = Dio(
      BaseOptions(
        // baseUrl: 'http://10.100.241.185:4000',
        baseUrl: 'http://127.0.0.1:4000',
        receiveTimeout: 3000,
      ),
    );
    return App(
      preferences: preferences,
      httpClient: httpClient,
    );
  });
}
