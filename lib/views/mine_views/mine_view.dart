import 'package:flutter/material.dart';

class MineView extends StatefulWidget {
  const MineView({super.key});

  @override
  State<MineView> createState() => _MineViewState();
}

class _MineViewState extends State<MineView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F2F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Mine'),
      ),
      body: const Center(
        child: Text('这是之后会实现的我的页面'),
      ),
    );
  }
}
