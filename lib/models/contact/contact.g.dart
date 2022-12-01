// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: avoid_dynamic_calls

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contact _$ContactFromJson(Map<String, dynamic> json) {
  return Contact(
    email: json['email'] as String,
    firstname: json['firstname'] as String,
    lastname: json['lastname'] as String,
    publicKey: json['publickey'] as String,
    registrationDate: DateTime.parse(json['registerdate'] as String).toLocal(),
  );
}
