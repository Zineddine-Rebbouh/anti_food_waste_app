// lib/features/chat/models/chat_models.dart

class ChatMessage {
  final String id;
  final String conversationId;
  final String sender;
  final String senderName;
  final String messageType;
  final String textContent;
  final List<ChatCard> cards;
  final List<QuickReply> quickReplies;
  final String? intent;
  final double? confidence;
  final double? sentimentScore;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.senderName,
    this.messageType = 'text',
    required this.textContent,
    this.cards = const [],
    this.quickReplies = const [],
    this.intent,
    this.confidence,
    this.sentimentScore,
    this.isRead = false,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      conversationId: json['conversation'] as String? ?? '',
      sender: json['sender'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? '',
      messageType: json['message_type'] as String? ?? 'text',
      textContent: json['text_content'] as String? ?? '',
      cards: (json['cards'] as List<dynamic>?)
              ?.map((e) => ChatCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      quickReplies: (json['quick_replies'] as List<dynamic>?)
              ?.map((e) => QuickReply.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      intent: json['intent'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      sentimentScore: (json['sentiment_score'] as num?)?.toDouble(),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation': conversationId,
      'sender': sender,
      'sender_name': senderName,
      'message_type': messageType,
      'text_content': textContent,
      'cards': cards.map((e) => e.toJson()).toList(),
      'quick_replies': quickReplies.map((e) => e.toJson()).toList(),
      'intent': intent,
      'confidence': confidence,
      'sentiment_score': sentimentScore,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class QuickReply {
  final String label;
  final String action;
  final Map<String, dynamic> payload;

  QuickReply({
    required this.label,
    required this.action,
    this.payload = const {},
  });

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      label: json['label'] as String? ?? '',
      action: json['action'] as String? ?? '',
      payload: (json['payload'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'action': action,
      'payload': payload,
    };
  }
}

class ChatCard {
  final String type;
  final String title;
  final String subtitle;
  final String imageUrl;
  final Map<String, dynamic> data;
  final List<ChatAction> actions;

  ChatCard({
    required this.type,
    required this.title,
    this.subtitle = '',
    this.imageUrl = '',
    this.data = const {},
    this.actions = const [],
  });

  factory ChatCard.fromJson(Map<String, dynamic> json) {
    return ChatCard(
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      data: (json['data'] as Map<String, dynamic>?) ?? {},
      actions: (json['actions'] as List<dynamic>?)
              ?.map((e) => ChatAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'data': data,
      'actions': actions.map((e) => e.toJson()).toList(),
    };
  }
}

class ChatAction {
  final String label;
  final String action;
  final Map<String, dynamic> payload;

  ChatAction({
    required this.label,
    required this.action,
    this.payload = const {},
  });

  factory ChatAction.fromJson(Map<String, dynamic> json) {
    return ChatAction(
      label: json['label'] as String? ?? '',
      action: json['action'] as String? ?? '',
      payload: (json['payload'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'action': action,
      'payload': payload,
    };
  }
}

class Conversation {
  final String id;
  final String userRole;
  final String status;
  final String resolutionStatus;
  final int? satisfactionRating;
  final int messageCount;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.userRole,
    required this.status,
    required this.resolutionStatus,
    this.satisfactionRating,
    this.messageCount = 0,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String? ?? '',
      userRole: json['user_role'] as String? ?? '',
      status: json['status'] as String? ?? '',
      resolutionStatus: json['resolution_status'] as String? ?? '',
      satisfactionRating: json['satisfaction_rating'] as int?,
      messageCount: json['message_count'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_role': userRole,
      'status': status,
      'resolution_status': resolutionStatus,
      'satisfaction_rating': satisfactionRating,
      'message_count': messageCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
