part of 'chat_cubit.dart';

/// The current responder mode for the conversation.
enum ConversationMode {
  ai,    // Gemini AI is responding
  admin, // Human admin has taken over
}

class ChatState extends Equatable {
  final bool isLoading;
  final String? error;
  final String? conversationId;
  final String? conversationStatus;
  final ConversationMode mode;
  final bool isEscalated;
  final bool isTyping;
  final bool isAdminTyping;
  final String? adminName;          // Name of the current admin (when mode=admin)
  final String? modeChangeMessage;  // System message shown on mode switch
  final List<ChatMessage> messages;
  final List<Conversation> conversations; // All user conversations

  const ChatState({
    this.isLoading = false,
    this.error,
    this.conversationId,
    this.conversationStatus,
    this.mode = ConversationMode.ai,
    this.isEscalated = false,
    this.isTyping = false,
    this.isAdminTyping = false,
    this.adminName,
    this.modeChangeMessage,
    this.messages = const [],
    this.conversations = const [],
  });

  bool get isAdminMode => mode == ConversationMode.admin;
  bool get isAiMode => mode == ConversationMode.ai;
  bool get isResolved => conversationStatus == 'resolved' || conversationStatus == 'ended';

  ChatState copyWith({
    bool? isLoading,
    String? error,
    String? conversationId,
    String? conversationStatus,
    ConversationMode? mode,
    bool? isEscalated,
    bool? isTyping,
    bool? isAdminTyping,
    String? adminName,
    String? modeChangeMessage,
    List<ChatMessage>? messages,
    List<Conversation>? conversations,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Always passed explicitly — null clears the error
      conversationId: conversationId ?? this.conversationId,
      conversationStatus: conversationStatus ?? this.conversationStatus,
      mode: mode ?? this.mode,
      isEscalated: isEscalated ?? this.isEscalated,
      isTyping: isTyping ?? this.isTyping,
      isAdminTyping: isAdminTyping ?? this.isAdminTyping,
      adminName: adminName ?? this.adminName,
      modeChangeMessage: modeChangeMessage ?? this.modeChangeMessage,
      messages: messages ?? this.messages,
      conversations: conversations ?? this.conversations,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        conversationId,
        conversationStatus,
        mode,
        isEscalated,
        isTyping,
        isAdminTyping,
        adminName,
        modeChangeMessage,
        messages,
        conversations,
      ];
}
