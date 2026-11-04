abstract class AiCoachRepository {
  Stream<String> generateStreamingAdvice({
    required String prompt,
    required void Function(String reasoning) onReasoningGenerated,
  });
}
