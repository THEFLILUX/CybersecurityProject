import 'package:chat_frontend/home/home.dart';
import 'package:chat_frontend/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.read<HomeCubit>().checkLogin()) {
      context.go('/login');
    }

    context.read<HomeCubit>().setInitialVariables();

    if (context
        .select<HomeCubit, List<Contact>>((cubit) => cubit.state.contacts)
        .isEmpty) {
      context.read<HomeCubit>().loadContacts();
    }
    final selectedContact = context.select<HomeCubit, Contact?>(
      (cubit) => cubit.state.selectedContact,
    );
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state.showDetailsDialog) {
          context.read<HomeCubit>().hideDetailsDialog();
          showDetailsDialog(context: context, contact: state.selectedContact!);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.indigo[900],
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const LeftPanel(),
              const SizedBox(width: 20),
              RightPanel(selectedContact: selectedContact),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showDetailsDialog({
    required BuildContext context,
    required Contact contact,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Detalles del contacto',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'Nombre: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${contact.firstname} ${contact.lastname}',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'Fecha de registro: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: contact.registrationDate.formatted,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'Llave pública: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: contact.publicKey,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'Correo: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: contact.email,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}

class LeftPanel extends StatelessWidget {
  const LeftPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                minRadius: 30,
                maxRadius: 30,
                child: Text(
                  context
                      .select<HomeCubit, String>(
                        (cubit) => cubit.state.firstName,
                      )[0]
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                '${context.select<HomeCubit, String>(
                  (cubit) => cubit.state.firstName,
                )} ${context.select<HomeCubit, String>(
                  (cubit) => cubit.state.lastName,
                )}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              IconButton(
                onPressed: () {
                  context.read<HomeCubit>().logout();
                  context.go('/login');
                },
                icon: const Icon(
                  Icons.logout_outlined,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              const Icon(
                Icons.person_outline_outlined,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Agregar contacto',
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: context.read<HomeCubit>().newContactEmailChanged,
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(
                  size: 30,
                  Icons.add_circle_outline,
                  color: Colors.white,
                ),
                onPressed: () => context.read<HomeCubit>().addNewContact(),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(
                  size: 30,
                  Icons.update_outlined,
                  color: Colors.white,
                ),
                onPressed: () => context.read<HomeCubit>().loadContacts(),
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state.contactStatus.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (state.contacts.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'No tienes contactos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: SingleChildScrollView(
                    child: Column(
                      children: state.contacts
                          .map(
                            (contact) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: InkWell(
                                onTap: () => context
                                    .read<HomeCubit>()
                                    .changeContactChat(contact),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      minRadius: 20,
                                      maxRadius: 20,
                                      child: Text(
                                        contact.firstname[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${contact.firstname} '
                                          '${contact.lastname}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          contact.email,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RightPanel extends StatelessWidget {
  const RightPanel({
    super.key,
    required this.selectedContact,
  });

  final Contact? selectedContact;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 7,
      child: selectedContact == null
          ? const SizedBox(
              child: Center(
                child: Text(
                  'Selecciona un contacto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        minRadius: 25,
                        maxRadius: 25,
                        child: Text(
                          selectedContact!.firstname[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${selectedContact!.firstname} '
                            '${selectedContact!.lastname}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            selectedContact!.email,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        height: 40,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () =>
                              context.read<HomeCubit>().showDetailsDialog(),
                          child: const Text(
                            'Ver detalles',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const ChatView(),
                ],
              ),
            ),
    );
  }
}

class ChatView extends StatelessWidget {
  const ChatView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final chatMessages = context.select<HomeCubit, List<types.TextMessage>>(
      (cubit) => cubit.state.chatMessages,
    );
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.decryptionStatus.isLoading) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        } else if (state.decryptionStatus.isSuccess) {
          return Expanded(
            child: Chat(
              theme: DefaultChatTheme(
                backgroundColor: Colors.indigo[900]!,
              ),
              messages: chatMessages,
              user: types.User(
                id: context.select<HomeCubit, String>(
                  (cubit) => cubit.state.email,
                ),
              ),
              onSendPressed: (p0) => context.read<HomeCubit>().sendNewMessage(
                    p0,
                  ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

extension on DateTime {
  String get formatted {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(this);
  }
}

// Piero: 2vmcsCCXtvVkW74qfPlUMP4+MkRbbd3bShkTz4JKc0I=|MXKQAK4zabG3nu5LM4THxcGd/0iuSvdRkS/TSXY+US8=|4db5vu9S8TBOlET30/5/gj98n7+khN+jck8/Ik8qF6M=

// Angel: vNrCUnF15B774JonCcBwBAryPHdmQ+eN/tvQTIrKhtI=|Leak77ouLCWt5LAHdGUl+/4nwMQbbybjlNbvMTz+AsQ=|HBw16H8LLa4NA5hTN6NrtxlmDAk+M81ip5ApWmE68lQ=

// Jorge: h+C5kaiWOWa/CRV8S5AyhtxzqZRWFvnw2SfeLF9E/xk=|dsa8UiRfSrNqCERRing8yhGRho3r0I9O8lOvzBOrO4Y=|I1o06uGE5G4nxzhsVPP2aIpfvjrjOW8dnQygXv+eMSg=

// Anthony: zWQcb+4GPRONLbK7a486rZShGpXx+TSot6n58hhQavA=|5fqMys0hZaZ+xTp3trvnl9+oZekVVZFrEu39QdyotJ8=|3/Uq2plxV1btzV1QMewYdHnlaRjCnIPa7PjJ2E4qiLc=
