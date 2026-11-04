import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/ai_coach_message.dart';
import 'reasoning_chip.dart';

class ChatMessageBubble extends StatelessWidget {
  final AiCoachMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.reasoning != null && message.reasoning!.isNotEmpty)
            ReasoningChip(reasoning: message.reasoning!),
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldPrimary.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.emeraldPrimary, width: 1.2),
                  ),
                  child: const Center(
                    child: Icon(Icons.psychology_rounded, size: 18, color: AppColors.emeraldPrimary),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.emeraldPrimary : AppColors.darkSurface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    border: isUser ? null : Border.all(color: AppColors.darkBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: isUser ? Colors.black : Colors.white,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      if (message.isStreaming) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 8,
                          height: 14,
                          color: isUser ? Colors.black : AppColors.emeraldPrimary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
