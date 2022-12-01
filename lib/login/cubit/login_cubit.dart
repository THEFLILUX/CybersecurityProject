import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required SharedPreferences preferences,
    required Dio httpClient,
  }) : super(
          LoginState(
            preferences: preferences,
            httpClient: httpClient,
          ),
        );

  bool checkLogin() {
    if (state.preferences.getString('token') != null &&
        state.preferences.getString('privateKey') != null) {
      return true;
    }
    return false;
  }

  Future<void> emailChanged(String value) async {
    emit(state.copyWith(email: value));
  }

  Future<void> passwordChanged(String value) async {
    emit(state.copyWith(password: value));
  }

  Future<void> togglePasswordVisibility() async {
    emit(state.copyWith(hidePassword: !state.hidePassword));
  }

  Future<void> privateKeyChanged(String value) async {
    emit(state.copyWith(privateKey: value));
  }

  Future<void> login() async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final response = await state.httpClient.post<Map<String, dynamic>>(
        '/login',
        data: {
          'email': state.email,
          'password': state.password,
        },
      );
      if (response.statusCode == 200) {
        await state.preferences.setString(
          'token',
          response.data!['token'] as String,
        );
        await state.preferences.setString(
          'privateKey',
          state.privateKey,
        );
        await Future<void>.delayed(const Duration(seconds: 1));
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(state.copyWith(status: LoginStatus.failure));
      }
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.failure));
    }
  }
}
