import 'package:chat_frontend/register/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.read<RegisterCubit>().checkLogin()) {
      context.go('/home');
    }
    if (context.select<RegisterCubit, RegisterStatus>(
          (cubit) => cubit.state.status,
        ) ==
        RegisterStatus.success) {
      const snackBar = SnackBar(
        content: Text(
          'Usuario registrado correctamente. '
          'Se ha copiado la llave privada al portapapeles.',
        ),
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return BlocListener<RegisterCubit, RegisterState>(
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
                'Registro',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nombre',
                ),
                onChanged: (value) =>
                    context.read<RegisterCubit>().nameChanged(value),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Apellido',
                ),
                onChanged: (value) =>
                    context.read<RegisterCubit>().lastNameChanged(value),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Correo',
                ),
                onChanged: (value) =>
                    context.read<RegisterCubit>().emailChanged(value),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      context.select<RegisterCubit, bool>(
                        (cubit) => cubit.state.hidePassword,
                      )
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => context
                        .read<RegisterCubit>()
                        .togglePasswordVisibility(),
                  ),
                ),
                obscureText: context.select<RegisterCubit, bool>(
                  (cubit) => cubit.state.hidePassword,
                ),
                onChanged: (value) =>
                    context.read<RegisterCubit>().passwordChanged(value),
              ),
              const SizedBox(height: 20),
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (context, state) => SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.read<RegisterCubit>().register(),
                    child: !state.status.isLoading
                        ? const Text(
                            'Registrarse',
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
                  const Text('¿Ya tienes cuenta?'),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Inicia sesión'),
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
