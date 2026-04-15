import 'package:flutter/material.dart';
import '../data/services/groq_chat_service.dart';

class AIChatFullScreen extends StatefulWidget {
  final String userName;
  const AIChatFullScreen({super.key, required this.userName});

  @override
  State<AIChatFullScreen> createState() => _AIChatFullScreenState();
}

class _AIChatFullScreenState extends State<AIChatFullScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final GroqChatService _groqService = GroqChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Чат с Нейрошей'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.indigo : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(msg['content'] ?? '', style: TextStyle(color: isUser ? Colors.white : Colors.black)),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Спроси что-нибудь...'))),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    final text = _controller.text;
    _controller.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    
    try {
      final response = await _groqService.getResponse(text);
      setState(() => _messages.add({'role': 'assistant', 'content': response}));
    } catch (e) {
      setState(() => _messages.add({'role': 'assistant', 'content': 'Упс! Мой мозг немного перегрелся. Попробуй позже!'}));
    } finally {
      setState(() => _isLoading = false);
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }
}
