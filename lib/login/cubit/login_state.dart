part of 'login_cubit.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == LoginStatus.initial;
  bool get isLoading => this == LoginStatus.loading;
  bool get isSuccess => this == LoginStatus.success;
  bool get isFailure => this == LoginStatus.failure;
}

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    required this.preferences,
    required this.httpClient,
    this.email = '',
    this.password = '',
    this.hidePassword = true,
    this.privateKey = '',
  });

  final LoginStatus status;
  final SharedPreferences preferences;
  final Dio httpClient;
  final String email;
  final String password;
  final bool hidePassword;
  final String privateKey;

  @override
  List<Object> get props => [
        status,
        preferences,
        httpClient,
        email,
        password,
        hidePassword,
        privateKey,
      ];

  LoginState copyWith({
    LoginStatus? status,
    SharedPreferences? preferences,
    Dio? httpClient,
    String? email,
    String? password,
    bool? hidePassword,
    String? privateKey,
  }) {
    return LoginState(
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      httpClient: httpClient ?? this.httpClient,
      email: email ?? this.email,
      password: password ?? this.password,
      hidePassword: hidePassword ?? this.hidePassword,
      privateKey: privateKey ?? this.privateKey,
    );
  }
}
