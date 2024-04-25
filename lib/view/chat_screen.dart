import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _selectedLanguage = "en-US";
  List<dynamic> _items = [];
  @override
  void initState() {
    loadItems();
    super.initState();
  }

  Future loadItems() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/translations/$_selectedLanguage.json");
    setState(() {
      _items = json.decode(data)["items"];
    });
  }

  final currentTime = DateTime.now();

  final ChatUser _currentUser = ChatUser(
    id: "1",
    firstName: "Athii",
    lastName: "Ammu",
  );

  List<ChatMessage> _messages = <ChatMessage>[];

  final TextEditingController _textEditingController = TextEditingController();

  void searchItem(String word) async {
    final user = ChatUser(id: _currentUser.id);

    // Add user input message to the chat (on the right)
    setState(() {
      _messages.insert(
        0,
        ChatMessage(createdAt: currentTime, text: word, user: user),
      );
    });

    // Search for the item in the items list
    var result = _items.firstWhere(
      (item) =>
          item['name'].toLowerCase() == word.toLowerCase().trim() ||
          item['name'].toLowerCase() == '${word}s'.toLowerCase().trim(),
      orElse: () => null,
    );

    String translatedResult;
    if (result != null) {
      translatedResult = "${result["name"]} - ${result["description"]}";
    } else {
      translatedResult = "not_found_message".tr();
    }

    // Use a different user for the response (on the left)
    final responseUser = ChatUser(id: 'user1');

    // Add the translated result to the chat (on the left)
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          createdAt: currentTime,
          text: translatedResult,
          user: responseUser,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              items: [
                DropdownMenuItem(value: "en-US", child: Text("english")),
                DropdownMenuItem(value: "ml-IN", child: Text("മലയാളം")),
                DropdownMenuItem(value: "ar-SA", child: Text("العربية")),
              ],
              onChanged: (newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                  context.setLocale(
                    Locale(newValue.split('-')[0], newValue.split('-')[1]),
                  );
                  loadItems();
                  _messages.clear();
                });
              },
            ),
          ),
        ],
        title: Text("app_bar_text".tr()),
      ),
      body: Column(
        children: [
          Expanded(
            child: DashChat(
              currentUser: _currentUser,
              messageOptions: const MessageOptions(
                currentUserContainerColor: Color.fromARGB(255, 153, 173, 253),
                containerColor: Color.fromARGB(255, 221, 215, 215),
                textColor: Colors.black,
              ),
              onSend: (ChatMessage m) {
                searchItem(m.text);
              },
              messages: _messages,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
