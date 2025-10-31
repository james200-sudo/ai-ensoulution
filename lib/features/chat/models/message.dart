class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;
  final String? imageUrl;
  final String? imageData; // Base64 encoded image data for web persistence
  final String? audioUrl; // Path to audio file
  final int? audioDuration; // Duration in seconds

  const Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.imageUrl,
    this.imageData,
    this.audioUrl,
    this.audioDuration,
  });

  Message copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageStatus? status,
    String? imageUrl,
    String? imageData,
    String? audioUrl,
    int? audioDuration,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      imageData: imageData ?? this.imageData,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.name,
      'imageUrl': imageUrl,
      'imageData': imageData,
      'audioUrl': audioUrl,
      'audioDuration': audioDuration,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      imageUrl: json['imageUrl'] as String?,
      imageData: json['imageData'] as String?,
      audioUrl: json['audioUrl'] as String?,
      audioDuration: json['audioDuration'] as int?,
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  failed,
  streaming,
}
