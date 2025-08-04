import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_voce_chat/controller/chat_controllers/chat_controller.dart';
import 'package:my_voce_chat/controller/todo_controllers/todo_controller.dart';
import 'package:my_voce_chat/controller/chat_controllers/chat_user_controller.dart';
import 'package:my_voce_chat/views/chat_views/chat_login_view/chat_login_view.dart';
import 'package:my_voce_chat/views/chat_views/chat_settings_view/chat_settings_view.dart';
import 'package:my_voce_chat/views/home_views/the_home_view.dart';
import 'package:my_voce_chat/views/mine_views/newwork_view/newwork_settings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 注册Dio实例
  Get.put(Dio());

  // 注册Controllers
  Get.put(TodoController());
  Get.put(ChatUserController());
  Get.put(ChatController());

  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 隐藏状态栏与底部导航
    SystemChrome.setEnabledSystemUIMode(
      // 配合 SystemUiOverlayStyle 的 systemNavigationBarColor: Colors.transparent，可达到底部系统导航透明效果；
      // 如果系统导航是3按钮导航，那么可以设置 systemNavigationBarContrastEnforced： false，取消默认的半透明效果。
      // 全屏展示
      SystemUiMode.edgeToEdge,
      //默认隐藏，若从边缘滑动会显示，过会儿会自动隐藏（安卓，iOS）
      //  SystemUiMode.immersiveSticky,
      //默认隐藏，若从边缘滑动会显示，不自动隐藏（安卓）
      //  SystemUiMode.immersive,
      //默认隐藏，点击屏幕任一地方都后会显示，不自动隐藏（安卓，不过在 pixel4 上测试无效）
      //SystemUiMode.leanBack,
    );

    return GetMaterialApp(
      home: Scaffold(
        body: TheHomeView(),
      ),
      routes: {
        '/network': (context) => NetworkSettingsView(),
        '/chatLogin': (context) => ChatLoginView(),
        '/chatSettings': (context) => ChatSettingsView(),
      },
    );
  }
}
