import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/theme_store.dart';
import '../stores/ai_coach_store.dart';
import '../widgets/chat_message_bubble.dart';

class AiCoachView extends StatefulWidget {
  const AiCoachView({super.key});

  @override
  State<AiCoachView> createState() => _AiCoachViewState();
}

class _AiCoachViewState extends State<AiCoachView> {
  late final AiCoachStore _store;
  final ThemeStore _themeStore = sl<ThemeStore>();
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
    return Observer(
      builder: (_) {
        final _ = _themeStore.themeMode;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

        Widget buildChatList() {
          return Observer(
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
          );
        }

        Widget buildInputField() {
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Ask your AI Coach about training, HRV, or macros...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
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
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        Widget buildQuickPromptsList({bool horizontal = true}) {
          if (horizontal) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
              ),
              child: SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _store.quickPromptChips.length,
                  itemBuilder: (context, index) {
                    final prompt = _store.quickPromptChips[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        label: Text(
                          prompt,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
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
            );
          } else {
            return Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI RECOMMENDATIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._store.quickPromptChips.map(
                      (prompt) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ActionChip(
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            label: Text(
                              prompt,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              _store.sendUserPrompt(prompt);
                              _scrollToBottom();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Text('On-Device AI Recovery Coach'),
              ],
            ),
          ),
          body: SafeArea(
            child: isLandscape
                ? Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: buildQuickPromptsList(horizontal: false),
                      ),
                      VerticalDivider(color: colorScheme.outlineVariant, width: 1),
                      Expanded(
                        flex: 7,
                        child: Column(
                          children: [
                            Expanded(child: buildChatList()),
                            buildInputField(),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      buildQuickPromptsList(horizontal: true),
                      Expanded(child: buildChatList()),
                      buildInputField(),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
