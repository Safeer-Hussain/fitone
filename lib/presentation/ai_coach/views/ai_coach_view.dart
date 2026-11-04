import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../stores/ai_coach_store.dart';
import '../widgets/chat_message_bubble.dart';

class AiCoachView extends StatefulWidget {
  const AiCoachView({super.key});

  @override
  State<AiCoachView> createState() => _AiCoachViewState();
}

class _AiCoachViewState extends State<AiCoachView> {
  late final AiCoachStore _store;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _store = sl<AiCoachStore>();
    _store.initialize();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.emeraldPrimary, size: 20),
            SizedBox(width: 8),
            Text('On-Device AI Recovery Coach'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick action chips bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.darkBorder)),
            ),
            child: SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _store.quickPromptChips.length,
                itemBuilder: (context, index) {
                  final prompt = _store.quickPromptChips[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: AppColors.darkSurfaceElevated,
                      label: Text(
                        prompt,
                        style: const TextStyle(fontSize: 11, color: AppColors.emeraldPrimary, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        _store.sendUserPrompt(prompt);
                        _scrollToBottom();
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                final messages = _store.messages;
                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ChatMessageBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: AppColors.darkSurface,
              border: Border(top: BorderSide(color: AppColors.darkBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Ask your AI Coach about training, HRV, or macros...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (text) {
                      _store.sendUserPrompt(text);
                      _textController.clear();
                      _scrollToBottom();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Observer(
                  builder: (_) => IconButton.filled(
                    onPressed: _store.isStreaming
                        ? null
                        : () {
                            _store.sendUserPrompt(_textController.text);
                            _textController.clear();
                            _scrollToBottom();
                          },
                    icon: const Icon(Icons.arrow_upward_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.emeraldPrimary,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
