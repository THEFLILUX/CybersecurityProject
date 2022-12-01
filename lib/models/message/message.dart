import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

/// {@template message}
/// Message model
/// {@endtemplate}
@JsonSerializable(createToJson: false)
class Message extends Equatable {
  /// {@macro message}
  const Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.message,
    required this.datetime,
  });

  /// Creates a [Message] from a JSON object
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  /// Message id
  final String id;

  /// Message sender
  final String sender;

  /// Message receiver
  final String receiver;

  /// Message content
  final String message;

  /// Message date
  final DateTime datetime;

  @override
  List<Object?> get props => [
        id,
        sender,
        receiver,
        message,
        datetime,
      ];
}
