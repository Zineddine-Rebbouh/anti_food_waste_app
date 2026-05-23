import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:anti_food_waste_app/features/chat/models/chat_models.dart';
import 'package:anti_food_waste_app/features/chat/services/chat_service.dart';
import 'package:anti_food_waste_app/features/chat/services/chat_cache_service.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatService _chatService;
  final ChatCacheService _cache = ChatCacheService();
  StreamSubscription? _messageSubscription;
  String? _conversationId;

  ChatCubit(this._chatService) : super(const ChatState()) {
    _listenToWebSocket();
  }

  // --------------------------------------------------------------------------
  // WebSocket stream handler — routes every event to the correct state update
  // --------------------------------------------------------------------------

  void _listenToWebSocket() {
    _messageSubscription = _chatService.messageStream.listen((data) {
      final type = data['type'] as String?;

      switch (type) {

        // ── Regular messages ──────────────────────────────────────────────────
        case 'bot_message':
        case 'new_message':
          final messageData = data['message'];
          if (messageData != null) {
            final newMessage = ChatMessage.fromJson(messageData as Map<String, dynamic>);
            
            if (_conversationId != null) {
              _cache.appendMessage(_conversationId!, newMessage);
            }

            final messages = List<ChatMessage>.from(state.messages);
            
            if (newMessage.sender == 'user') {
              // Try to find and replace the optimistic temp message
              final tempIndex = messages.indexWhere((m) => 
                m.id.startsWith('temp_') && m.textContent == newMessage.textContent);
              
              if (tempIndex != -1) {
                messages[tempIndex] = newMessage;
              } else {
                // Only add if not already present (to avoid duplicates if REST also added it)
                if (!messages.any((m) => m.id == newMessage.id)) {
                  messages.add(newMessage);
                }
              }
            } else {
              // For bot/admin messages, just append
              // Also clean up any older temp messages that might be stuck (optional)
              messages.add(newMessage);
            }

            emit(state.copyWith(
              messages: messages,
              isTyping: false,
              isAdminTyping: false,
              conversationStatus: data['conversation_status'] as String? ?? state.conversationStatus,
              error: null,
            ));
          }

        // ── Typing indicators ─────────────────────────────────────────────────
        case 'bot_typing':
          emit(state.copyWith(isTyping: data['is_typing'] as bool? ?? false));

        case 'admin_typing':
          emit(state.copyWith(
            isAdminTyping: data['is_typing'] as bool? ?? false,
            adminName: data['admin_name'] as String? ?? state.adminName,
          ));

        case 'user_typing':
          // Reflected back — ignore on user side
          break;

        // ── 🔑 Mode change: AI ↔ Admin ──────────────────────────────────────
        case 'mode_change':
          final rawMode = data['mode'] as String?;
          final newMode = rawMode == 'admin'
              ? ConversationMode.admin
              : ConversationMode.ai;
          final adminName = data['admin_name'] as String?;
          final modeMsg = data['message'] as String?;

          emit(state.copyWith(
            mode: newMode,
            isEscalated: newMode == ConversationMode.admin,
            adminName: adminName,
            modeChangeMessage: modeMsg,
            isTyping: false,
            isAdminTyping: false,
            error: null,
          ));

        // ── Message status (admin mode pending reply) ─────────────────────────
        case 'message_status':
          // Conversation is in admin mode — AI won't reply
          if (data['status'] == 'admin_mode') {
            emit(state.copyWith(
              isTyping: false,
              mode: ConversationMode.admin,
            ));
          }

        // ── Connection events ─────────────────────────────────────────────────
        case 'connection_established':
          _conversationId = data['conversation_id'] as String?;
          final rawMode = data['mode'] as String?;
          final initialMode = rawMode == 'admin'
              ? ConversationMode.admin
              : ConversationMode.ai;
          emit(state.copyWith(
            mode: initialMode,
            error: null,
          ));

        case 'connection_status':
          // Reconnection progress — no state change needed beyond what
          // the service already handles, but we can surface failed state
          if (data['status'] == 'failed') {
            emit(state.copyWith(
              error: 'Connection lost. Please check your internet connection.',
            ));
          }

        // ── Escalation ────────────────────────────────────────────────────────
        case 'escalation_alert':
          emit(state.copyWith(
            isEscalated: true,
            conversationStatus: 'escalated',
          ));

        // ── Conversation resolved ─────────────────────────────────────────────
        case 'conversation_resolved':
          emit(state.copyWith(conversationStatus: 'resolved'));

        default:
          break;
      }
    });
  }

  // --------------------------------------------------------------------------
  // Public API
  // --------------------------------------------------------------------------

  Future<void> startSession({bool forceNew = false}) async {
    // 0. Load all conversations for the sidebar/history
    await loadConversations();

    // 1. Show cached messages instantly for snappy UX
    final lastConvId = _cache.getLastConversationId();
    if (lastConvId != null && state.messages.isEmpty && !forceNew) {
      final cachedMsgs = _cache.getMessages(lastConvId);
      if (cachedMsgs.isNotEmpty) {
        emit(state.copyWith(messages: cachedMsgs, conversationId: lastConvId));
      }
    }

    emit(state.copyWith(isLoading: state.messages.isEmpty, error: null));

    try {
      final data = await _chatService.startSession(forceNew: forceNew);
      final conversationData = data['conversation'] as Map<String, dynamic>;
      final isNew = data['is_new'] == true;
      final greetingData = data['greeting'];

      _conversationId = conversationData['id'] as String?;

      // Determine initial mode from backend
      final rawMode = conversationData['mode'] as String?;
      final initialMode = rawMode == 'admin'
          ? ConversationMode.admin
          : ConversationMode.ai;

      var messages = <ChatMessage>[];

      if (!isNew) {
        final historyData = await _chatService.getHistory();
        final msgsList = historyData['messages'] as List<dynamic>? ?? [];
        messages = msgsList
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList();
      } else if (greetingData != null) {
        messages = [ChatMessage.fromJson(greetingData as Map<String, dynamic>)];
      }

      if (_conversationId != null) {
        _cache.saveMessages(_conversationId!, messages);
      }

      emit(state.copyWith(
        isLoading: false,
        conversationId: _conversationId,
        conversationStatus: conversationData['status'] as String?,
        mode: initialMode,
        isEscalated: conversationData['status'] == 'escalated' ||
            conversationData['mode'] == 'admin',
        messages: messages,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: state.messages.isEmpty ? e.toString() : null,
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    if (state.isTyping) {
      debugPrint('Debouncing: AI is already typing...');
      return;
    }

    // Optimistically add user message
    final tempMsg = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: _conversationId ?? '',
      sender: 'user',
      senderName: 'You',
      textContent: text,
      createdAt: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, tempMsg],
      isTyping: state.isAiMode, // Show AI typing only in AI mode
      error: null,
    ));

    if (_conversationId != null) {
      _cache.appendMessage(_conversationId!, tempMsg);
    }

    // Try WebSocket first
    final wsSuccess = _chatService.sendWsMessage(text);
    if (!wsSuccess) {
      // REST fallback
      try {
        final response =
            await _chatService.sendMessageRest(text, _conversationId);

        // In admin mode the response message is null (pending admin reply)
        final botMsgData = response['message'];
        final responseStatus = response['status'] as String?;

        if (responseStatus == 'admin_mode' || state.isAdminMode) {
          // Admin mode — no bot reply, just stop the typing indicator
          emit(state.copyWith(
            isTyping: false,
            mode: ConversationMode.admin,
          ));
        } else if (botMsgData != null) {
          final botMessage = ChatMessage.fromJson(botMsgData as Map<String, dynamic>);
          if (_conversationId != null) {
            _cache.appendMessage(_conversationId!, botMessage);
          }
          emit(state.copyWith(
            messages: [...state.messages, botMessage],
            isTyping: false,
            conversationStatus: response['conversation_status'] as String? ??
                state.conversationStatus,
            error: null,
          ));
        }
      } catch (e) {
        var errorMsg = 'Network error. Message not sent.';
        if (e is Exception) {
          final msg = e.toString();
          if (msg.startsWith('Exception: ')) {
            errorMsg = msg.substring(11);
          } else {
            errorMsg = msg;
          }
        }
        
        emit(state.copyWith(
          isTyping: false,
          error: errorMsg,
        ));
      }
    }
  }

  void sendTypingIndicator(bool isTyping) {
    _chatService.sendTypingIndicator(isTyping);
  }

  Future<void> rateMessage(String messageId, bool isHelpful) async {
    await _chatService.submitFeedback(messageId, isHelpful);
  }

  Future<void> loadConversations() async {
    try {
      final list = await _chatService.getConversationsList();
      final conversations = list
          .map((c) => Conversation.fromJson(c as Map<String, dynamic>))
          .toList();
      emit(state.copyWith(conversations: conversations));
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    }
  }

  Future<void> startNewChat() async {
    emit(const ChatState(isLoading: true));
    await startSession(forceNew: true);
    await loadConversations();
  }

  Future<void> switchConversation(String id) async {
    if (id == _conversationId) return;
    
    emit(state.copyWith(isLoading: true, messages: []));
    
    try {
      final historyData = await _chatService.getHistory(id);
      final conversationData = historyData['conversation'] as Map<String, dynamic>;
      final msgsList = historyData['messages'] as List<dynamic>? ?? [];
      final messages = msgsList
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
      
      _conversationId = id;
      _cache.saveMessages(id, messages);
      
      // Update service state and reconnect WebSocket
      _chatService.disconnect();
      // Wait a moment for disconnect to settle
      await Future.delayed(const Duration(milliseconds: 100));
      await _chatService.connectTo(id);
      
      emit(state.copyWith(
        isLoading: false,
        conversationId: id,
        messages: messages,
        conversationStatus: conversationData['status'] as String?,
        mode: conversationData['mode'] == 'admin' ? ConversationMode.admin : ConversationMode.ai,
        isEscalated: conversationData['status'] == 'escalated' || conversationData['mode'] == 'admin',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> endSession([int? rating]) async {
    if (_conversationId != null) {
      await _chatService.endSession(_conversationId!, rating);
      emit(state.copyWith(conversationStatus: 'resolved'));
      await loadConversations();
    }
  }

  /// Dismiss the mode change banner after the user has seen it
  void acknowledgeModeChange() {
    emit(state.copyWith(modeChangeMessage: null));
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _chatService.dispose();
    return super.close();
  }
}
