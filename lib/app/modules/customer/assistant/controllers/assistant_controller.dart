import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:string_similarity/string_similarity.dart';
import '../data/chat_message.dart';
import '../data/farm_knowledge.dart';
import '../data/groq_service.dart';

// Controller managing chat conversation state, knowledge retrieval, and AI fallback
class AssistantController extends GetxController {
  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;

  // Suggestion chips sirf welcome state mein dikhti hain
  final RxBool showSuggestions = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadWelcomeMessage();
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // Harvey ka initial welcome message chat mein add karta hai
  void _loadWelcomeMessage() {
    messages.add(
      ChatMessage(
        text:
            "Hi, I'm Harvey — your HarvestHub farm assistant. Ask me about fresh produce, storage tips, health benefits, or how to use the marketplace!",
        isUser: false,
      ),
    );
  }

  // GroqErrorType ke hisaab se situation-specific fallback message return karta hai
  String _fallbackFor(GroqErrorType errorType) {
    switch (errorType) {
      case GroqErrorType.network:
        return "I'm having trouble connecting right now. Please check your internet and try again.";
      case GroqErrorType.rateLimit:
        return "I'm a bit overloaded at the moment — please try again in a few seconds.";
      case GroqErrorType.unknown:
      case GroqErrorType.none:
        return "I don't have a good answer for that yet. Try asking about fruits, vegetables, storage, nutrition, or how to use the app.";
    }
  }

  // Predefined knowledge base mein se 0.4 se zyada score wala best match dhoondta hai
  String? findKnowledgeMatch(String query) {
    double highestScore = 0.0;
    String? bestAnswer;
    String? bestQuestion;

    for (final entry in farmKnowledge) {
      final question = entry['question'] ?? '';
      final score = StringSimilarity.compareTwoStrings(
        query.toLowerCase(),
        question.toLowerCase(),
      );
      if (score > highestScore) {
        highestScore = score;
        bestAnswer = entry['answer'];
        bestQuestion = question;
      }
    }

    final isKbMatch = highestScore > 0.4;
    debugPrint(
      '[KB DEBUG] Query: "$query" | Best Question: "$bestQuestion" | Match score: ${highestScore.toStringAsFixed(3)}, threshold: 0.4, going to [${isKbMatch ? "KB" : "Groq"}]',
    );

    return isKbMatch ? bestAnswer : null;
  }

  // Chip tap hone par seedha text pass karke sendMessage() call karta hai
  void sendFromChip(String chipText) {
    inputController.text = chipText;
    sendMessage();
  }

  // User ka sawal process karta hai aur knowledge base ya Groq se jawab lata hai
  Future<void> sendMessage() async {
    final text = inputController.text.trim();
    if (text.isEmpty || isLoading.value) return;

    // Pehla user message aane par chips hide kar do
    if (showSuggestions.value) showSuggestions.value = false;

    inputController.clear();
    messages.add(ChatMessage(text: text, isUser: true));
    _scrollToBottom();
    isLoading.value = true;

    try {
      final kbAnswer = findKnowledgeMatch(text);
      if (kbAnswer != null) {
        // Knowledge base match mila — directly use karo
        messages.add(ChatMessage(text: kbAnswer, isUser: false));
      } else {
        // Groq se jawab lo aur error type check karo
        final result = await GroqService.askGroq(text);
        if (result.errorType == GroqErrorType.none && result.answer.isNotEmpty) {
          messages.add(ChatMessage(text: result.answer, isUser: false));
        } else {
          messages.add(ChatMessage(text: _fallbackFor(result.errorType), isUser: false));
        }
      }
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  // Chat list ko aakhri message par auto-scroll karta hai
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
