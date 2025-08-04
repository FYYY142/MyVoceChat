import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../controller/chat_controllers/chat_user_controller.dart';

class ChatSettingsView extends StatefulWidget {
  @override
  _ChatSettingsViewState createState() => _ChatSettingsViewState();
}

class _ChatSettingsViewState extends State<ChatSettingsView> {
  final ChatUserController _chatUserController = Get.find();
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  double _fontSize = 16.0;
  String _selectedLanguage = '中文';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // 用户信息卡片
          Obx(() => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(_chatUserController.currentUser?.name ?? '未登录'),
                  subtitle:
                      Text(_chatUserController.currentUser?.email ?? '请先登录'),
                  trailing: Icon(Icons.edit),
                  onTap: () {
                    // 编辑用户信息
                  },
                ),
              )),

          SizedBox(height: 20),

          // Token信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Token信息',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.key, color: Colors.green),
                      title: Text('访问Token'),
                      subtitle: Text(
                        _chatUserController.token.isNotEmpty
                            ? '${_chatUserController.token.substring(0, 20)}...'
                            : '无',
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          if (_chatUserController.token.isNotEmpty) {
                            Clipboard.setData(
                                ClipboardData(text: _chatUserController.token));
                            Fluttertoast.showToast(msg: '访问Token已复制到剪贴板');
                          }
                        },
                      ),
                      onTap: () {
                        _showTokenDialog('访问Token', _chatUserController.token);
                      },
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.refresh, color: Colors.orange),
                      title: Text('刷新Token'),
                      subtitle: Text(
                        _chatUserController.refreshToken.isNotEmpty
                            ? '${_chatUserController.refreshToken.substring(0, 20)}...'
                            : '无',
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          if (_chatUserController.refreshToken.isNotEmpty) {
                            Clipboard.setData(ClipboardData(
                                text: _chatUserController.refreshToken));
                            Fluttertoast.showToast(msg: '刷新Token已复制到剪贴板');
                          }
                        },
                      ),
                      onTap: () {
                        _showTokenDialog(
                            '刷新Token', _chatUserController.refreshToken);
                      },
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.dns, color: Colors.blue),
                      title: Text('服务器ID'),
                      subtitle: Text(
                        _chatUserController.serverId.isNotEmpty
                            ? _chatUserController.serverId
                            : '无',
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          if (_chatUserController.serverId.isNotEmpty) {
                            Clipboard.setData(ClipboardData(
                                text: _chatUserController.serverId));
                            Fluttertoast.showToast(msg: '服务器ID已复制到剪贴板');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // 刷新Token按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final success = await _chatUserController.toRefreshToken();
                    if (success) {
                      Fluttertoast.showToast(msg: 'Token刷新成功');
                    } else {
                      Fluttertoast.showToast(msg: 'Token刷新失败');
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('刷新Token'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  void _showTokenDialog(String title, String token) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              token.isNotEmpty ? token : '无Token',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (token.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: token));
                Fluttertoast.showToast(msg: '$title已复制到剪贴板');
              }
            },
            child: Text('复制'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('关闭'),
          ),
        ],
      ),
    );
  }
}
