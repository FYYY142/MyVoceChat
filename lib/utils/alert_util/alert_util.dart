import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AlertUtil {
  /// 显示错误信息弹窗
  /// [message] 错误信息文本
  /// [title] 弹窗标题，默认为"错误提示"
  static void showErrorDialog({
    required String message,
    String title = "错误提示",
  }) {
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            IconButton(
              onPressed: () => _copyToClipboard(message),
              icon: const Icon(
                Icons.copy,
                size: 20,
                color: Colors.grey,
              ),
              tooltip: "复制错误信息",
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            message,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("确定"),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  static void showLogDialog({
    required String message,
    String title = "内容调试",
  }) {
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 54, 135, 255),
              ),
            ),
            IconButton(
              onPressed: () => _copyToClipboard(message),
              icon: const Icon(
                Icons.copy,
                size: 20,
                color: Colors.grey,
              ),
              tooltip: "复制调试信息",
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            message,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("确定"),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// 复制文本到剪贴板
  static void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "错误信息已复制到剪贴板",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  static Future<dynamic> showLoginViewDialog(
      {required Future<dynamic> Function(String username, String password)
          onLogin,
      String title = '登录',
      String limit = 'number'}) async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return await Get.dialog<dynamic>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SizedBox(width: 40),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close),
                      ))
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                keyboardType: limit == 'email'
                    ? TextInputType.emailAddress
                    : TextInputType.text,
                decoration: InputDecoration(
                  labelText: limit == 'email' ? '邮箱' : '用户名',
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  labelStyle: const TextStyle(color: Colors.green),
                  errorText: limit == 'email' &&
                          usernameController.text.isNotEmpty &&
                          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(usernameController.text)
                      ? '请输入有效的邮箱格式'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  labelStyle: TextStyle(color: Colors.green),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // 校验用户名/邮箱
                    if (usernameController.text.trim().isEmpty) {
                      Fluttertoast.showToast(
                        msg: limit == 'email' ? "请输入邮箱" : "请输入用户名",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                      return;
                    }

                    // 如果是邮箱模式，校验邮箱格式
                    if (limit == 'email' &&
                        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(usernameController.text.trim())) {
                      Fluttertoast.showToast(
                        msg: "请输入有效的邮箱格式",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                      return;
                    }

                    // 校验密码
                    if (passwordController.text.trim().isEmpty) {
                      Fluttertoast.showToast(
                        msg: "请输入密码",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                      return;
                    }

                    final response = await onLogin(
                        usernameController.text.trim(),
                        passwordController.text.trim());
                    Get.back(result: response);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                  child: const Text('登录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
