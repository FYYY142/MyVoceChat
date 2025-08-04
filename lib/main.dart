import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_voce_chat/controller/todo_controllers/todo_controller.dart';
import 'package:my_voce_chat/views/home_views/the_home_view.dart';
import 'package:my_voce_chat/views/mine_views/newwork_view/newwork_settings_view.dart';

void main() {
  // 注册Dio实例
  Get.put(Dio());

  // 注册TodoController
  Get.put(TodoController());
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        body: TheHomeView(),
      ),
      routes: {
        '/network': (context) => NetworkSettingsView(),
      },
    );
  }
}
