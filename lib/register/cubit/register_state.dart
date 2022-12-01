part of 'register_cubit.dart';

enum RegisterStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == RegisterStatus.initial;
  bool get isLoading => this == RegisterStatus.loading;
  bool get isSuccess => this == RegisterStatus.success;
  bool get isFailure => this == RegisterStatus.failure;
}

class RegisterState extends Equatable {
  const RegisterState({
    this.status = RegisterStatus.initial,
    required this.preferences,
    required this.httpClient,
    this.name = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.hidePassword = true,
  });

  final RegisterStatus status;
  final SharedPreferences preferences;
  final Dio httpClient;
  final String name;
  final String lastName;
  final String email;
  final String password;
  final bool hidePassword;

  @override
  List<Object> get props => [
        status,
        preferences,
        httpClient,
        name,
        lastName,
        email,
        password,
        hidePassword,
      ];

  RegisterState copyWith({
    RegisterStatus? status,
    SharedPreferences? preferences,
    Dio? httpClient,
    String? name,
    String? lastName,
    String? email,
    String? password,
    bool? hidePassword,
  }) {
    return RegisterState(
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      httpClient: httpClient ?? this.httpClient,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      hidePassword: hidePassword ?? this.hidePassword,
    );
  }
}
