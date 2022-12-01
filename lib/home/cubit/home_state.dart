part of 'home_cubit.dart';

enum ContactStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == ContactStatus.initial;
  bool get isLoading => this == ContactStatus.loading;
  bool get isSuccess => this == ContactStatus.success;
  bool get isFailure => this == ContactStatus.failure;
}

enum DecryptionStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == DecryptionStatus.initial;
  bool get isLoading => this == DecryptionStatus.loading;
  bool get isSuccess => this == DecryptionStatus.success;
  bool get isFailure => this == DecryptionStatus.failure;
}

class HomeState extends Equatable {
  const HomeState({
    this.contactStatus = ContactStatus.initial,
    this.decryptionStatus = DecryptionStatus.initial,
    required this.preferences,
    required this.httpClient,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.newContactEmail = '',
    this.selectedContact,
    this.contacts = const <Contact>[],
    this.messages = const <Message>[],
    this.showDetailsDialog = false,

    // For chat
    this.fromAuthor,
    this.toAuthor,
    this.chatMessages = const <types.TextMessage>[],
  });

  final ContactStatus contactStatus;
  final DecryptionStatus decryptionStatus;
  final SharedPreferences preferences;
  final Dio httpClient;
  final String firstName;
  final String lastName;
  final String email;
  final String newContactEmail;
  final Contact? selectedContact;
  final List<Contact> contacts;
  final List<Message> messages;
  final bool showDetailsDialog;

  // For chat
  final types.User? fromAuthor;
  final types.User? toAuthor;
  final List<types.TextMessage> chatMessages;

  @override
  List<Object?> get props => [
        contactStatus,
        decryptionStatus,
        preferences,
        httpClient,
        firstName,
        lastName,
        email,
        newContactEmail,
        selectedContact,
        contacts,
        messages,
        showDetailsDialog,

        // For chat
        fromAuthor,
        toAuthor,
        chatMessages,
      ];

  HomeState copyWith({
    ContactStatus? contactStatus,
    DecryptionStatus? decryptionStatus,
    SharedPreferences? preferences,
    Dio? httpClient,
    String? firstName,
    String? lastName,
    String? email,
    String? newContactEmail,
    Contact? selectedContact,
    List<Contact>? contacts,
    List<Message>? messages,
    bool? showDetailsDialog,

    // For chat
    types.User? fromAuthor,
    types.User? toAuthor,
    List<types.TextMessage>? chatMessages,
  }) {
    return HomeState(
      contactStatus: contactStatus ?? this.contactStatus,
      decryptionStatus: decryptionStatus ?? this.decryptionStatus,
      preferences: preferences ?? this.preferences,
      httpClient: httpClient ?? this.httpClient,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      newContactEmail: newContactEmail ?? this.newContactEmail,
      selectedContact: selectedContact ?? this.selectedContact,
      contacts: contacts ?? this.contacts,
      messages: messages ?? this.messages,
      showDetailsDialog: showDetailsDialog ?? this.showDetailsDialog,

      // For chat
      fromAuthor: fromAuthor ?? this.fromAuthor,
      toAuthor: toAuthor ?? this.toAuthor,
      chatMessages: chatMessages ?? this.chatMessages,
    );
  }
}
