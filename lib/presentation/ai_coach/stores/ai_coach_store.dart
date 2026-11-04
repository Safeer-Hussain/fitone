import 'dart:async';
import 'package:mobx/mobx.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/ai_coach_message.dart';
import '../../../domain/repositories/ai_coach_repository.dart';

class AiCoachStore {
  final AiCoachRepository aiCoachRepository;

  AiCoachStore({required this.aiCoachRepository});

  final _messages = ObservableList<AiCoachMessage>();
  List<AiCoachMessage> get messages => _messages;

  final _isStreaming = Observable<bool>(false);
  bool get isStreaming => _isStreaming.value;

  final _activeReasoning = Observable<String?>(null);
  String? get activeReasoning => _activeReasoning.value;

  final List<String> quickPromptChips = const [
    "Adjust Today's Workout for Low HRV",
    "Generate High-Protein Meal Plan",
    "Analyze Last 7 Days Recovery",
  ];

  void initialize() {
    if (_messages.isEmpty) {
      _messages.add(
        AiCoachMessage(
          id: const Uuid().v4(),
          text: 'Hello Safeer. I am your on-device AI Sports Scientist and Recovery Coach. '
              'I continuously analyze your AuraRing HRV, sleep architecture, and SQLite macro logs. '
              'How can I optimize your training, recovery, or nutrition today?',
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<void> sendUserPrompt(String prompt) async {
    if (prompt.trim().isEmpty || _isStreaming.value) return;

    final userMsg = AiCoachMessage(
      id: const Uuid().v4(),
      text: prompt.trim(),
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    final aiMsgId = const Uuid().v4();
    final aiPlaceholder = AiCoachMessage(
      id: aiMsgId,
      text: '',
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    runInAction(() {
      _messages.add(userMsg);
      _messages.add(aiPlaceholder);
      _isStreaming.value = true;
      _activeReasoning.value = null;
    });

    final stream = aiCoachRepository.generateStreamingAdvice(
      prompt: prompt,
      onReasoningGenerated: (reasoning) {
        runInAction(() {
          _activeReasoning.value = reasoning;
          final idx = _messages.indexWhere((m) => m.id == aiMsgId);
          if (idx != -1) {
            _messages[idx] = _messages[idx].copyWith(reasoning: reasoning);
          }
        });
      },
    );

    StringBuffer fullResponse = StringBuffer();
    await for (final token in stream) {
      fullResponse.write(token);
      runInAction(() {
        final idx = _messages.indexWhere((m) => m.id == aiMsgId);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(text: fullResponse.toString());
        }
      });
    }

    runInAction(() {
      final idx = _messages.indexWhere((m) => m.id == aiMsgId);
      if (idx != -1) {
        _messages[idx] = _messages[idx].copyWith(isStreaming: false);
      }
      _isStreaming.value = false;
      _activeReasoning.value = null;
    });
  }
}
