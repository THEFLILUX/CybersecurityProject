import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:chat_frontend/models/models.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required SharedPreferences preferences,
    required Dio httpClient,
  }) : super(
          HomeState(
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

  Future<void> changeContactChat(Contact contact) async {
    emit(
      state.copyWith(
        decryptionStatus: DecryptionStatus.loading,
        selectedContact: contact,
        toAuthor: types.User(
          id: contact.email,
        ),
      ),
    );
    try {
      final response = await state.httpClient.get<Map<String, dynamic>>(
        '/chat',
        queryParameters: {
          'email': contact.email,
        },
        options: Options(
          headers: {
            'Authorization': state.preferences.getString('token'),
          },
        ),
      );
      if (response.statusCode == 200) {
        final messages = (response.data!['messages'] as List<dynamic>) //Parsea en una lista de mensajes
            .map(
              (dynamic message) =>
                  Message.fromJson(message as Map<String, dynamic>),
            )
            .toList();
        final chatMessages = <types.TextMessage>[];
        if (messages.isEmpty) {
          emit(
            state.copyWith(
              messages: messages,
              chatMessages: chatMessages,
              decryptionStatus: DecryptionStatus.success,
            ),
          );
          return;
        }

        // Cargar llave privada
        final privateKeyString =
            state.preferences.getString('privateKey')!.split('|');
        final keyPair = EcKeyPair.lazy(
          () async => EcKeyPairData(
            d: base64.decode(privateKeyString[0]),
            x: base64.decode(privateKeyString[1]),
            y: base64.decode(privateKeyString[2]),
            type: KeyPairType.p256,
          ),
        );

        // Cargar llave pública del contacto
        final decodedX = base64.decode(contact.publicKey.split('|')[0]);
        final decodedY = base64.decode(contact.publicKey.split('|')[1]);
        final publicKeyContact = EcPublicKey(
          x: decodedX,
          y: decodedY,
          type: KeyPairType.p256,
        );

        // Crear secreto compartido
        final algorithm = Ecdh.p256(length: 32);
        final sharedSecret = await algorithm.sharedSecretKey(
          keyPair: keyPair,
          remotePublicKey: publicKeyContact,
        );

        for (final message in messages) {
          // Desencriptar mensaje
          final aesAlgorithm = AesGcm.with256bits();
          final secretBox = SecretBox(
            base64.decode(message.message.split('|')[0]),
            nonce: base64.decode('3759'),
            mac: Mac(base64.decode(message.message.split('|')[1])),
          );
          final decryptedMessage = await aesAlgorithm.decrypt(
            secretBox,
            secretKey: sharedSecret,
          );

          final chatMessage = types.TextMessage(
            id: message.id,
            author: types.User(
              id: message.sender,
            ),
            createdAt: message.datetime.millisecondsSinceEpoch,
            text: utf8.decode(decryptedMessage),
          );
          chatMessages.insert(0, chatMessage);
        }
        await Future<void>.delayed(const Duration(seconds: 1));
        emit(
          state.copyWith(
            messages: messages,
            chatMessages: chatMessages,
            decryptionStatus: DecryptionStatus.success,
          ),
        );
      } else {
        emit(state.copyWith(decryptionStatus: DecryptionStatus.failure));
      }
    } catch (e) {
      emit(state.copyWith(decryptionStatus: DecryptionStatus.failure));
    }
  }

  Future<void> sendNewMessage(types.PartialText newMessage) async {
    emit(state.copyWith(decryptionStatus: DecryptionStatus.loading));
    try {
      // Cargar llave privada
      final privateKeyString =
          state.preferences.getString('privateKey')!.split('|');
      // final keyPair = EcKeyPairData(
      //   d: base64.decode(privateKeyString[0]),
      //   x: base64.decode(privateKeyString[1]),
      //   y: base64.decode(privateKeyString[2]),
      //   type: KeyPairType.p256,
      // );
      final keyPair = EcKeyPair.lazy(
        () async => EcKeyPairData(
          d: base64.decode(privateKeyString[0]),
          x: base64.decode(privateKeyString[1]),
          y: base64.decode(privateKeyString[2]),
          type: KeyPairType.p256,
        ),
      );

      // Cargar llave pública del contacto
      final decodedX = base64.decode(
        state.selectedContact!.publicKey.split('|')[0],
      );
      final decodedY = base64.decode(
        state.selectedContact!.publicKey.split('|')[1],
      );
      final publicKeyContact = EcPublicKey(
        x: decodedX,
        y: decodedY,
        type: KeyPairType.p256,
      );

      // Crear secreto compartido
      final algorithm = Ecdh.p256(length: 32);
      final sharedSecret = await algorithm.sharedSecretKey(
        keyPair: keyPair,
        remotePublicKey: publicKeyContact,
      );

      // Encriptar mensaje
      final messageString = utf8.encode(newMessage.text);
      final aesAlgorithm = AesGcm.with256bits();
      final nonce = base64.decode('3759');
      final secretBox = await aesAlgorithm.encrypt(
        messageString,
        secretKey: sharedSecret,
        nonce: nonce,
      );

      final response = await state.httpClient.post<Map<String, dynamic>>(
        '/message',
        options: Options(
          headers: {
            'Authorization': state.preferences.getString('token'),
          },
        ),
        data: {
          'message':
              '${base64.encode(secretBox.cipherText)}|${base64.encode(secretBox.mac.bytes)}',
          'receiver': state.selectedContact!.email,
        },
      );
      if (response.statusCode == 200) {
        final textMessage = types.TextMessage(
          id: const Uuid().v4(),
          author: state.fromAuthor!,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          text: newMessage.text,
        );
        final chatMessages = state.chatMessages..insert(0, textMessage);
        emit(
          state.copyWith(
            chatMessages: chatMessages,
            decryptionStatus: DecryptionStatus.success,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> newContactEmailChanged(String email) async {
    emit(state.copyWith(newContactEmail: email));
  }

  Future<void> addNewContact() async {
    try {
      final response = await state.httpClient.post<Map<String, dynamic>>(
        '/contact',
        options: Options(
          headers: {
            'Authorization': state.preferences.getString('token'),
          },
        ),
        data: {
          'contact': state.newContactEmail,
        },
      );
      if (response.statusCode == 200) {
        await loadContacts();
        emit(state.copyWith(newContactEmail: ''));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> setInitialVariables() async {
    final token = state.preferences.getString('token') ?? '';
    final decodedToken = JwtDecoder.decode(token);
    emit(
      state.copyWith(
        firstName: decodedToken['firstname'] != null
            ? decodedToken['firstname'] as String
            : 'Nombre',
        lastName: decodedToken['lastname'] != null
            ? decodedToken['lastname'] as String
            : 'Apellido',
        email: decodedToken['email'] != null
            ? decodedToken['email'] as String
            : 'Correo',
        fromAuthor: types.User(
          id: decodedToken['email'] != null
              ? decodedToken['email'] as String
              : 'Correo',
        ),
      ),
    );
  }

  Future<void> logout() async {
    await state.preferences.clear();
  }

  Future<void> showDetailsDialog() async {
    emit(state.copyWith(showDetailsDialog: true));
  }

  Future<void> hideDetailsDialog() async {
    emit(state.copyWith(showDetailsDialog: false));
  }

  Future<void> loadContacts() async {
    emit(state.copyWith(contactStatus: ContactStatus.loading));
    try {
      final response = await state.httpClient.get<Map<String, dynamic>>(
        '/home',
        options: Options(
          headers: {
            'Authorization': state.preferences.getString('token'),
          },
        ),
      );
      if (response.statusCode == 200) {
        final contacts = (response.data!['contacts'] as List<dynamic>)
            .map(
              (dynamic json) => Contact.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        await Future<void>.delayed(const Duration(seconds: 1));
        emit(
          state.copyWith(
            contactStatus: ContactStatus.success,
            contacts: contacts,
          ),
        );
      } else {
        emit(state.copyWith(contactStatus: ContactStatus.failure));
      }
    } catch (e) {
      emit(state.copyWith(contactStatus: ContactStatus.failure));
    }
  }

  Future<void> loadMessages(Contact contact) async {
    emit(state.copyWith(decryptionStatus: DecryptionStatus.loading));
    try {
      final response = await state.httpClient.get<Map<String, dynamic>>(
        '/chat',
        queryParameters: {
          'email': contact.email,
        },
        options: Options(
          headers: {
            'Authorization': state.preferences.getString('token'),
          },
        ),
      );
      if (response.statusCode == 200) {
        final messages = (response.data!['messages'] as List<dynamic>)
            .map(
              (dynamic json) => Message.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        // // Cargar llave privada
        // final privateKeyString =
        //     state.preferences.getString('privateKey')!.split('|');
        // final keyPair = EcKeyPair.lazy(
        //   () async => EcKeyPairData(
        //     d: base64.decode(privateKeyString[0]),
        //     x: base64.decode(privateKeyString[1]),
        //     y: base64.decode(privateKeyString[2]),
        //     type: KeyPairType.p256,
        //   ),
        // );

        // // Cargar llave pública del contacto
        // final decodedX = base64.decode(contact.publicKeyX);
        // final decodedY = base64.decode(contact.publicKeyY);
        // final publicKeyContact = EcPublicKey(
        //   x: decodedX,
        //   y: decodedY,
        //   type: KeyPairType.p256,
        // );

        // // Crear secreto compartido
        // final algorithm = Ecdh.p256(length: 32);
        // final sharedSecret = await algorithm.sharedSecretKey(
        //   keyPair: keyPair,
        //   remotePublicKey: publicKeyContact,
        // );

        // final decryptedMessages = messages.map(
        //   (message) async {
        //     final messageEncoded = utf8.encode(message.message);
        //     final aesAlgorithm = AesGcm.with256bits();
        //     final nonce = base64.decode('3759');
        //     final secretBox = await aesAlgorithm.encrypt(
        //       messageEncoded,
        //       secretKey: sharedSecret,
        //       nonce: nonce,
        //     );
        //     final mac = Mac(base64.decode('asd'));
        //   },
        // ).toList();
        emit(
          state.copyWith(
            decryptionStatus: DecryptionStatus.success,
            selectedContact: contact,
            messages: messages,
          ),
        );
      } else {
        emit(state.copyWith(decryptionStatus: DecryptionStatus.failure));
      }
    } catch (e) {
      emit(state.copyWith(decryptionStatus: DecryptionStatus.failure));
    }
  }
}
