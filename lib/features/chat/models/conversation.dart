import 'message.dart';

class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<Message> messages;
  final String? ragflowSessionId;

  const Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    required this.messages,
    this.ragflowSessionId,
  });

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    List<Message>? messages,
    String? ragflowSessionId,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messages: messages ?? this.messages,
      ragflowSessionId: ragflowSessionId ?? this.ragflowSessionId,
    );
  }

  // Generate a title from the first user message or first AI response for audio-first conversations
  static String generateTitle(List<Message> messages) {
    if (messages.isEmpty) return 'New Conversation';
    
    // Check if conversation starts with an audio message (empty content)
    final firstUserMessage = messages.firstWhere(
      (message) => message.isUser,
      orElse: () => Message(
        id: '',
        content: '',
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    
    // If first user message is audio (empty content), use first AI response as title
    if (firstUserMessage.content.trim().isEmpty && firstUserMessage.audioUrl != null) {
      final firstAIResponse = messages.firstWhere(
        (message) => !message.isUser && message.content.trim().isNotEmpty,
        orElse: () => Message(
          id: '',
          content: 'Voice Conversation',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      
      String title = firstAIResponse.content.trim();
      if (title.length > 50) {
        title = '${title.substring(0, 47)}...';
      }
      
      return title.isEmpty ? 'Voice Conversation' : title;
    }
    
    // Otherwise, use first user text message as title
    final firstTextMessage = messages.firstWhere(
      (message) => message.isUser && message.content.trim().isNotEmpty,
      orElse: () => Message(
        id: '',
        content: 'New Conversation',
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    
    String title = firstTextMessage.content.trim();
    if (title.length > 50) {
      title = '${title.substring(0, 47)}...';
    }
    
    return title.isEmpty ? 'New Conversation' : title;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastMessageAt': lastMessageAt.millisecondsSinceEpoch,
      'messages': messages.map((message) => message.toJson()).toList(),
      'ragflowSessionId': ragflowSessionId,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      lastMessageAt: DateTime.fromMillisecondsSinceEpoch(json['lastMessageAt'] as int),
      messages: (json['messages'] as List<dynamic>)
          .map((messageJson) => Message.fromJson(messageJson as Map<String, dynamic>))
          .toList(),
      ragflowSessionId: json['ragflowSessionId'] as String?,
    );
  }
}