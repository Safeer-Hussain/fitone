enum MessageSender { user, ai, system }

class AiCoachMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final String? reasoning;
  final bool isStreaming;

  AiCoachMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.reasoning,
    this.isStreaming = false,
  });

  AiCoachMessage copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    String? reasoning,
    bool? isStreaming,
  }) {
    return AiCoachMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      reasoning: reasoning ?? this.reasoning,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}
