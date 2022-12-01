import 'package:chat_frontend/home/home.dart';
import 'package:chat_frontend/login/login.dart';
import 'package:chat_frontend/register/register.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

GoRouter goRouter({
  required SharedPreferences preferences,
  required Dio httpClient,
}) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(
          preferences: preferences,
          httpClient: httpClient,
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterPage(
          preferences: preferences,
          httpClient: httpClient,
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomePage(
          preferences: preferences,
          httpClient: httpClient,
        ),
      ),
    ],
    debugLogDiagnostics: true,
  );
}
