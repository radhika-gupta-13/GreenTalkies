import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

// --- API CONFIGURATION ---
const String _systemInstruction =
    "You are Greenie, an AI assistant for the GreenTalkies community. Your goal is to provide concise, friendly, and helpful advice on sustainability, gardening, recycling, and eco-friendly living. Always encourage users to check the community for real-life advice and local events. Keep responses short and actionable.";
const String _modelName = 'gemini-2.5-flash-preview-09-2025';
const String _apiKey = 'AIzaSyCXQAEksR36Vtqz2km0lSchxh2tumtGebk';
const String _apiUrlBase = 'http://192.168.0.103:4000/api';

class _FetchResponse {
  final int status;
  final String _body;
  _FetchResponse(this.status, this._body);
  bool get ok => status >= 200 && status < 300;
  Future<dynamic> json() async => jsonDecode(_body);
}

Future<_FetchResponse> fetch(String url, Map<String, dynamic> options) async {
  final method = ((options['method'] as String?) ?? 'GET').toUpperCase();
  final headers = Map<String, String>.from(options['headers'] ?? {});
  final body = options['body'];
  final uri = Uri.parse(url);

  final client = HttpClient();
  try {
    final request = await client.openUrl(method, uri);

    // Set request headers
    headers.forEach((key, value) {
      request.headers.set(key, value);
    });

    // Write body if provided
    if (body != null) {
      if (body is String) {
        request.add(utf8.encode(body));
      } else if (body is List<int>) {
        request.add(body);
      } else {
        request.add(utf8.encode(jsonEncode(body)));
      }
    }

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    return _FetchResponse(response.statusCode, responseBody);
  } finally {
    client.close(force: true);
  }
}

// --- MAIN APPLICATION SETUP ---

void main() {
  // Define the primary color for a cohesive GreenTalkies theme (Dark Forest Green)
  final MaterialColor primaryGreen = MaterialColor(0xFF1B5E20, <int, Color>{
    50: const Color(0xFFE8F5E9),
    100: const Color(0xFFC8E6C9),
    200: const Color(0xFFA5D6A7),
    300: const Color(0xFF81C784),
    400: const Color(0xFF66BB6A),
    500: const Color(0xFF4CAF50),
    600: const Color(0xFF43A047),
    700: const Color(0xFF388E3C),
    800: const Color(0xFF2E7D32),
    900: const Color(0xFF1B5E20), // Darkest shade for theme
  });

  runApp(GreenTalkiesApp(primaryGreen: primaryGreen));
}

class GreenTalkiesApp extends StatelessWidget {
  final MaterialColor primaryGreen;

  const GreenTalkiesApp({super.key, required this.primaryGreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenTalkies - Ask Greenie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: primaryGreen,
        scaffoldBackgroundColor: const Color(
          0xFFF0FFF0,
        ), // Very light pale green background
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 60, 162, 65),
          foregroundColor: Colors.white,
        ),
        colorScheme:
            ColorScheme.fromSwatch(primarySwatch: primaryGreen).copyWith(
          secondary: Colors.lightGreen.shade400, // Accent color
        ),
        useMaterial3: true,
      ),
      // Set home directly to the Chatbot page
      home: const GreeniePage(),
    );
  }
}

class GreeniePage extends StatelessWidget {
  const GreeniePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ask Greenie 🤖',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color.fromARGB(255, 60, 162, 65),
        elevation: 0,
      ),
      // Only the Chatbot is in the body now
      body: const ChatbotScreen(),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'Greenie',
      'text':
          'Hi there! I\'m Greenie, your AI helper for sustainability. Ask me anything about eco-living, gardening, or recycling!',
    },
  ];
  bool _isSending = false;
  final ScrollController _scrollController = ScrollController();

  // Function to handle API call with exponential backoff
  Future<void> _generateContent(String prompt, {int retryCount = 0}) async {
    // Check for API Key before proceeding
    if (_apiKey.isEmpty) {
      setState(() {
        _messages.add({
          'role': 'Greenie',
          'text':
              '❌ API Key Missing! Please provide a Gemini API Key to use the chatbot.',
        });
        _isSending = false;
      });
      _scrollToBottom();
      return;
    }

    final apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent?key=$_apiKey';

    // Construct the chat history for context
    List<Map<String, dynamic>> chatHistory = [];
    for (var msg in _messages) {
      chatHistory.add({
        'role': msg['role'] == 'Greenie' ? 'model' : 'user',
        'parts': [
          {'text': msg['text']},
        ],
      });
    }
    // Add the new user prompt
    chatHistory.add({
      'role': 'user',
      'parts': [
        {'text': prompt},
      ],
    });

    final payload = {
      'contents': chatHistory,
      'tools': [
        {'google_search': {}},
      ], // Use Google Search for grounding
      'systemInstruction': {
        'parts': [
          {'text': _systemInstruction},
        ],
      },
    };

    try {
      // Use the global fetch function available in the web environment
      final response = await fetch(apiUrl, {
        'method': 'POST',
        'headers': {'Content-Type': 'application/json'},
        'body': jsonEncode(payload),
      });

      if (!response.ok) {
        throw Exception('API call failed with status: ${response.status}');
      }

      final result = await response.json();
      final text = result['candidates']?[0]?['content']?['parts']?[0]
              ?['text'] ??
          "Sorry, I couldn't generate a response.";

      setState(() {
        _messages.add({'role': 'Greenie', 'text': text});
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (retryCount < 3) {
        final delay = Duration(seconds: 1 << retryCount);
        // print('Retrying API call after $delay: $e');
        await Future.delayed(delay);
        return _generateContent(prompt, retryCount: retryCount + 1);
      } else {
        setState(() {
          _messages.add({
            'role': 'Greenie',
            'text':
                'I\'m sorry, there was an error connecting to my green brain. Please try again later.',
          });
          _isSending = false;
        });
        _scrollToBottom();
        // print('Final API error: $e');
      }
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty || _isSending) return;

    _textController.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isSending = true;
    });

    _scrollToBottom();
    _generateContent(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat List View
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 10, bottom: 8),
            reverse: false,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return ChatMessage(
                text: message['text']!,
                isGreenie: message['role'] == 'Greenie',
              );
            },
          ),
        ),

        // Typing Indicator/Loading
        if (_isSending)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text(
                  'Greenie is thinking...',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),

        // Input Area
        _buildTextComposer(context),
      ],
    );
  }

  Widget _buildTextComposer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: 'Ask Greenie a question...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              enabled: !_isSending,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send_rounded,
              color: _isSending || _textController.text.isEmpty
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
            ),
            onPressed: _isSending || _textController.text.isEmpty
                ? null
                : () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}

// Custom Widget for Chat Bubbles
class ChatMessage extends StatelessWidget {
  final String text;
  final bool isGreenie;

  const ChatMessage({required this.text, required this.isGreenie, super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment:
            isGreenie ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greenie Avatar
          if (isGreenie)
            CircleAvatar(
              backgroundColor: primaryColor,
              child: const Icon(
                Icons.psychology_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),

          const SizedBox(width: 8.0),

          // Message Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                // Use opacity variations of the primary color for better contrast
                color: isGreenie
                    ? primaryColor.withOpacity(0.12)
                    : primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16.0),
                  topRight: const Radius.circular(16.0),
                  bottomLeft:
                      isGreenie ? Radius.zero : const Radius.circular(16.0),
                  bottomRight:
                      isGreenie ? const Radius.circular(16.0) : Radius.zero,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isGreenie ? Colors.black87 : Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8.0),

          // User Avatar
          if (!isGreenie)
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: const Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: Colors.black54,
              ),
            ),
        ],
      ),
    );
  }
}
