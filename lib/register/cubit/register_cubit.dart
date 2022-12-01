import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({
    required SharedPreferences preferences,
    required Dio httpClient,
  }) : super(
          RegisterState(
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

  Future<void> nameChanged(String name) async {
    emit(state.copyWith(name: name));
  }

  Future<void> lastNameChanged(String lastName) async {
    emit(state.copyWith(lastName: lastName));
  }

  Future<void> emailChanged(String email) async {
    emit(state.copyWith(email: email));
  }

  Future<void> passwordChanged(String password) async {
    emit(state.copyWith(password: password));
  }

  Future<void> togglePasswordVisibility() async {
    emit(state.copyWith(hidePassword: !state.hidePassword));
  }

  Future<void> register() async {
    emit(state.copyWith(status: RegisterStatus.loading));
    try {
      // Generar pares de llaves
      final algorithm = Ecdh.p256(length: 32);
      final keyPair = await algorithm.newKeyPair();
      final publicKey = await keyPair.extractPublicKey();

      // Enviar request al servidor
      final response = await state.httpClient.post<Map<String, dynamic>>(
        '/signup',
        data: {
          'firstname': state.name,
          'lastname': state.lastName,
          'email': state.email,
          'password': state.password,
          'publickey':
              '${base64.encode(publicKey.x)}|${base64.encode(publicKey.y)}',
        },
      );
      await Future<void>.delayed(const Duration(seconds: 1));
      if (response.statusCode == 200) {
        // Copiar llave privada al portapapeles
        final keyPairData = await keyPair.extract();
        final keyPairD = base64.encode(keyPairData.d);
        final keyPairX = base64.encode(keyPairData.x);
        final keyPairY = base64.encode(keyPairData.y);
        await FlutterClipboard.controlC('$keyPairD|$keyPairX|$keyPairY');

        // Guardar token en preferencias
        await state.preferences.setString(
          'token',
          response.data!['token'] as String,
        );

        // Guardar llave privada en preferencias
        await state.preferences.setString(
          'privateKey',
          '$keyPairD|$keyPairX|$keyPairY',
        );

        emit(state.copyWith(status: RegisterStatus.success));
      } else {
        emit(state.copyWith(status: RegisterStatus.failure));
      }
    } catch (e) {
      emit(state.copyWith(status: RegisterStatus.failure));
    }
  }
}
