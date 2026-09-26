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

  // Initial welcome message chat mein add karta hai
  void _loadWelcomeMessage() {
    messages.add(
      ChatMessage(
        text:
            "Hello! I am your HarvestHub Farm Assistant. Ask me anything about fresh produce, storage tips, health benefits, or how to use the marketplace!",
        isUser: false,
      ),
    );
  }

  // Predefined knowledge base mein se 0.4 se zyada score wala best match dhoondta hai
  String? findKnowledgeMatch(String query) {
    double highestScore = 0.0;
    String? bestAnswer;

    for (final entry in farmKnowledge) {
      final question = entry['question'] ?? '';
      final score = StringSimilarity.compareTwoStrings(
        query.toLowerCase(),
        question.toLowerCase(),
      );
      if (score > highestScore) {
        highestScore = score;
        bestAnswer = entry['answer'];
      }
    }

    return highestScore > 0.4 ? bestAnswer : null;
  }

  // User ka sawal process karta hai aur knowledge base ya Groq se jawab lata hai
  Future<void> sendMessage() async {
    final text = inputController.text.trim();
    if (text.isEmpty || isLoading.value) return;

    inputController.clear();
    messages.add(ChatMessage(text: text, isUser: true));
    _scrollToBottom();
    isLoading.value = true;

    try {
      final kbAnswer = findKnowledgeMatch(text);
      if (kbAnswer != null) {
        messages.add(ChatMessage(text: kbAnswer, isUser: false));
      } else {
        final aiAnswer = await GroqService.askGroq(text);
        messages.add(ChatMessage(text: aiAnswer, isUser: false));
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
