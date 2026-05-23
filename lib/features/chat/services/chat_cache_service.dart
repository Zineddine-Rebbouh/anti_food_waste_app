import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:anti_food_waste_app/features/chat/models/chat_models.dart';

class ChatCacheService {
  static const String _messagesBoxName = 'chat_messages_box';
  static const String _metaBoxName = 'chat_meta_box';
  
  // Singleton
  static final ChatCacheService _instance = ChatCacheService._internal();
  factory ChatCacheService() => _instance;
  ChatCacheService._internal();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    await Hive.openBox(_messagesBoxName);
    await Hive.openBox(_metaBoxName);
    _isInitialized = true;
  }

  /// Save full message history for a conversation
  Future<void> saveMessages(String conversationId, List<ChatMessage> messages) async {
    final box = Hive.box(_messagesBoxName);
    final jsonList = messages.map((m) => m.toJson()).toList();
    await box.put(conversationId, jsonEncode(jsonList));
    
    // Also track the last active conversation ID
    await Hive.box(_metaBoxName).put('last_conversation_id', conversationId);
  }

  /// Append a single message to local cache
  Future<void> appendMessage(String conversationId, ChatMessage message) async {
    final box = Hive.box(_messagesBoxName);
    final existingJson = box.get(conversationId);
    var list = <dynamic>[];
    if (existingJson != null) {
      list = jsonDecode(existingJson);
    }
    list.add(message.toJson());
    await box.put(conversationId, jsonEncode(list));
  }

  /// Retrieve cached messages
  List<ChatMessage> getMessages(String conversationId) {
    final box = Hive.box(_messagesBoxName);
    final jsonStr = box.get(conversationId);
    if (jsonStr == null) return [];
    
    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded.map((m) => ChatMessage.fromJson(m)).toList();
  }

  /// Get the last conversation ID the user was engaged in
  String? getLastConversationId() {
    return Hive.box(_metaBoxName).get('last_conversation_id');
  }

  /// Clear cache (on logout or session end)
  Future<void> clearCache() async {
    await Hive.box(_messagesBoxName).clear();
    await Hive.box(_metaBoxName).clear();
  }
}
