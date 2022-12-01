import 'package:chat_frontend/register/register.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({
    super.key,
    required this.preferences,
    required this.httpClient,
  });

  final SharedPreferences preferences;
  final Dio httpClient;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(
        preferences: preferences,
        httpClient: httpClient,
      ),
      child: const RegisterView(),
    );
  }
}
