// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    id: json['_id'] as String,
    sender: json['sender'] as String,
    receiver: json['receiver'] as String,
    message: json['message'] as String,
    datetime: DateTime.parse(json['date'] as String).toLocal(),
  );
}
