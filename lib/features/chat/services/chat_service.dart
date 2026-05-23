import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:anti_food_waste_app/core/network/api_client.dart';
import 'package:anti_food_waste_app/core/config/app_config.dart';
import 'package:anti_food_waste_app/core/services/token_storage.dart';

class ChatService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Reconnection state
  String? _currentConversationId;
  int _reconnectAttempts = 0;
  bool _isManualDisconnect = false;
  Timer? _reconnectTimer;
  static const int _maxReconnectAttempts = 10;
  static const Duration _baseDelay = Duration(seconds: 2);
  static const Duration _maxDelay = Duration(seconds: 30);

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// Starts a new session or resumes an active one.
  Future<Map<String, dynamic>> startSession({bool forceNew = false}) async {
    try {
      _isManualDisconnect = false;
      _reconnectAttempts = 0;
      
      final response = await ApiClient.dio.post(
        'chat/session/start/',
        queryParameters: forceNew ? {'force_new': 'true'} : null,
      );
      final convId = response.data['conversation']['id'];
      _currentConversationId = convId;
      
      await connectTo(convId);

      return response.data;
    } on DioException catch (e) {
      debugPrint('Error starting chat session: $e');
      throw Exception('Failed to start chat session');
    }
  }

  /// Connects specifically to a conversation ID
  Future<void> connectTo(String conversationId) async {
    _isManualDisconnect = false;
    _currentConversationId = conversationId;
    await _connectWebSocket(conversationId);
  }

  /// Sends a message via REST fallback if WS is not used/available.
  Future<Map<String, dynamic>> sendMessageRest(
      String message, String? conversationId) async {
    try {
      final response = await ApiClient.dio.post(
        'chat/message/',
        data: {
          'message': message,
          'conversation_id': conversationId,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('Error sending message via REST: $e');
      if (e.response != null && e.response!.data is Map) {
        final data = e.response!.data as Map;
        if (data.containsKey('error')) {
          throw Exception(data['error']);
        }
      }
      throw Exception('Failed to send message');
    }
  }

  /// Fetches history of a specific conversation or current if null
  Future<Map<String, dynamic>> getHistory([String? conversationId]) async {
    try {
      final response = await ApiClient.dio.get(
        'chat/history/',
        queryParameters: conversationId != null ? {'conversation_id': conversationId} : null,
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('Error fetching chat history: $e');
      throw Exception('Failed to load chat history');
    }
  }

  /// Fetches all conversations for the current user
  Future<List<dynamic>> getConversationsList() async {
    try {
      final response = await ApiClient.dio.get('chat/conversations/');
      return response.data['conversations'] ?? [];
    } on DioException catch (e) {
      debugPrint('Error fetching conversations list: $e');
      throw Exception('Failed to load chat history');
    }
  }

  /// Ends the session with optional rating
  Future<void> endSession(String conversationId, [int? rating]) async {
    try {
      _isManualDisconnect = true;
      _currentConversationId = null;
      _reconnectTimer?.cancel();
      
      await ApiClient.dio.post(
        'chat/session/end/',
        data: {
          'conversation_id': conversationId,
          if (rating != null) 'satisfaction_rating': rating,
        },
      );
      disconnect();
    } on DioException catch (e) {
      debugPrint('Error ending chat session: $e');
    }
  }

  /// Rate a bot message
  Future<void> submitFeedback(String messageId, bool isHelpful) async {
    try {
      await ApiClient.dio.post(
        'chat/feedback/',
        data: {
          'message_id': messageId,
          'is_helpful': isHelpful,
        },
      );
    } on DioException catch (e) {
      debugPrint('Error submitting feedback: $e');
    }
  }

  // --------------------------------------------------------------------------
  // WebSocket
  // --------------------------------------------------------------------------

  Future<void> _connectWebSocket(String conversationId) async {
    if (_isManualDisconnect) return;
    
    _channel?.sink.close();
    
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) {
        debugPrint('WebSocket: No access token found');
        return;
      }

      final wsUrl = AppConfig.baseUrl
          .replaceFirst('http', 'ws')
          .replaceFirst('api/v1/', 'ws/chat/$conversationId/?token=$token');

      debugPrint('WebSocket: Connecting to $wsUrl');
      
      // Use IOWebSocketChannel to allow setting a pingInterval for better stability on emulators
      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        pingInterval: const Duration(seconds: 15),
      );

      _channel!.stream.listen(
        (data) {
          _reconnectAttempts = 0; // Reset on successful message
          final decoded = jsonDecode(data);
          _messageController.add(decoded);
        },
        onError: (error) {
          debugPrint('WebSocket Error: $error');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('WebSocket Closed');
          _handleDisconnect();
        },
      );
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    if (_isManualDisconnect || _currentConversationId == null) return;
    
    // Check if we already have a timer running
    if (_reconnectTimer?.isActive ?? false) return;

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      
      // Calculate delay: baseDelay * 2^attempts (clamped to maxDelay)
      final delaySeconds = math.min(
        _baseDelay.inSeconds * math.pow(2, _reconnectAttempts - 1),
        _maxDelay.inSeconds,
      ).toInt();
      
      final delay = Duration(seconds: delaySeconds);
      
      debugPrint('WebSocket: Reconnecting in $delaySeconds seconds (Attempt $_reconnectAttempts)...');
      
      _reconnectTimer = Timer(delay, () {
        if (!_isManualDisconnect && _currentConversationId != null) {
          _connectWebSocket(_currentConversationId!);
        }
      });
      
      // Notify UI of connection issues
      _messageController.add({
        'type': 'connection_status',
        'status': 'reconnecting',
        'attempt': _reconnectAttempts,
      });
    } else {
      debugPrint('WebSocket: Max reconnection attempts reached.');
      _messageController.add({
        'type': 'connection_status',
        'status': 'failed',
      });
    }
  }

  bool sendWsMessage(String messageText) {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode({
          'type': 'user_message',
          'message': messageText,
        }));
        return true;
      } catch (e) {
        debugPrint('WebSocket sink add failed: $e');
        _handleDisconnect();
        return false;
      }
    }
    return false;
  }

  void sendTypingIndicator(bool isTyping) {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode({
          'type': 'typing_indicator',
          'is_typing': isTyping,
        }));
      } catch (e) {
        debugPrint('Failed to send typing indicator: $e');
      }
    }
  }

  void disconnect() {
    _isManualDisconnect = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
