import 'package:chat_frontend/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.read<LoginCubit>().checkLogin()) {
      context.go('/home');
    }
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.preferences.containsKey('token') &&
            state.preferences.containsKey('privateKey')) {
          context.go('/home');
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.email),
                ),
                onChanged: (value) =>
                    context.read<LoginCubit>().emailChanged(value),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      context.select<LoginCubit, bool>(
                        (cubit) => cubit.state.hidePassword,
                      )
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        context.read<LoginCubit>().togglePasswordVisibility(),
                  ),
                ),
                obscureText: context.select<LoginCubit, bool>(
                  (cubit) => cubit.state.hidePassword,
                ),
                onChanged: (value) =>
                    context.read<LoginCubit>().passwordChanged(value),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Llave privada',
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                onChanged: (value) =>
                    context.read<LoginCubit>().privateKeyChanged(value),
              ),
              const SizedBox(height: 20),
              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) => SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.read<LoginCubit>().login(),
                    child: !state.status.isLoading
                        ? const Text(
                            'Iniciar sesión',
                            style: TextStyle(fontSize: 20),
                          )
                        : const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta?'),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('Regístrate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
