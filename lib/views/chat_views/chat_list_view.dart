import 'package:flutter/material.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F2F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Chat List'),
      ),
      body: const Center(
        child: Text('这是之后会实现的聊天页面'),
      ),
    );
  }
}
