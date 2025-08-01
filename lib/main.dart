import 'package:flutter/material.dart';
import 'package:my_voce_chat/views/home_views/the_home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: TheHomeView(),
      ),
    );
  }
}
