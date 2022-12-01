import 'package:chat_frontend/login/login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    required this.preferences,
    required this.httpClient,
  });

  final SharedPreferences preferences;
  final Dio httpClient;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(
        preferences: preferences,
        httpClient: httpClient,
      ),
      child: const LoginView(),
    );
  }
}
