import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const WbcAiApp());
}

// 学校カラー
const wbcGreen = Color(0xFF3A9E48);
const wbcTeal = Color(0xFF4AB8A7);

class WbcAiApp extends StatelessWidget {
  const WbcAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WBC AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: wbcGreen),
        useMaterial3: true,
      ),
     home: const SplashScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {"role": "ai", "text": "こんにちは!WBC AIです。学校生活やビザについて質問してください😊"},
  ];

  bool _isLoading = false;
  // よくある質問
  final List<String> _quickQuestions = [
    "出席率は何%必要?",
    "ビザ更新の必要書類は?",
    "アルバイトは週何時間まで?",
    "卒業の条件は?",
    "就職活動はいつから?",
  ];

  void _sendQuickQuestion(String question) {
    _controller.text = question;
    _sendMessage();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _messages.add({"role": "ai", "text": "資料を検索しています📚..."});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': text}),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      String sourceText = "";
      if (data['sources'] != null) {
        for (final s in data['sources']) {
          sourceText += "\n📄 ${s['file']} P.${s['page']}";
        }
      }

      setState(() {
        _messages.removeLast();
        _messages.add({"role": "ai", "text": "${data['answer']}\n$sourceText"});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({"role": "ai", "text": "エラーが発生しました。サーバーが起動しているか確認してください。"});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: wbcGreen,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset('assets/images/logo.png'),
            ),
            const SizedBox(width: 10),
            const Text(
              'WBC AI',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: isUser ? wbcGreen : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          // ★よくある質問チップ(ここが新しい部分)
          Container(
            height: 44,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              itemCount: _quickQuestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      _quickQuestions[index],
                      style: const TextStyle(fontSize: 13, color: wbcGreen),
                    ),
                    backgroundColor: wbcGreen.withOpacity(0.08),
                    side: BorderSide(color: wbcGreen.withOpacity(0.4)),
                    onPressed: _isLoading
                        ? null
                        : () => _sendQuickQuestion(_quickQuestions[index]),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '質問を入力...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: wbcGreen,
                  iconSize: 28,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}