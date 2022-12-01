import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact.g.dart';

/// {@template contact}
/// Contact model
/// {@endtemplate}
@JsonSerializable(createToJson: false)
class Contact extends Equatable {
  /// {@macro contact}
  const Contact({
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.publicKey,
    required this.registrationDate,
  });

  /// Creates a [Contact] from a JSON object
  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);

  /// Contact email
  final String email;

  /// Contact first name
  final String firstname;

  /// Contact last name
  final String lastname;

  /// Contact public key
  final String publicKey;

  /// Contact registration date
  final DateTime registrationDate;

  @override
  List<Object?> get props => [
        email,
        firstname,
        lastname,
        publicKey,
        registrationDate,
      ];
}
