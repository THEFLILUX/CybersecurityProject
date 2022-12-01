import 'package:chat_frontend/home/home.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.preferences,
    required this.httpClient,
  });

  final SharedPreferences preferences;
  final Dio httpClient;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(
        preferences: preferences,
        httpClient: httpClient,
      ),
      child: const HomeView(),
    );
  }
}
