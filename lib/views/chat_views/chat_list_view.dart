import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_voce_chat/controller/chat_controllers/chat_user_controller.dart';
import 'package:my_voce_chat/controller/chat_controllers/chat_controller.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  ChatUserController _chatUserController = Get.find();
  ChatController _chatController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F2F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Voce Chat'),
        actions: [
          Text(_chatUserController.currentUser?.name ?? '游客',
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  MediaQuery.of(context).size.width - 100,
                  kToolbarHeight + 20,
                  20,
                  0,
                ),
                color: Colors.white,
                items: [
                  PopupMenuItem(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Text(
                        '设置',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    onTap: () {
                      // 设置按钮点击事件
                      Get.toNamed('/chatSettings');
                    },
                  ),
                  PopupMenuItem(
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Obx(() => Text(
                              _chatUserController.isLoggedIn ? '退出' : '登录',
                              style: TextStyle(color: Colors.green),
                            ))),
                    onTap: () {
                      // 退出按钮点击事件
                      if (_chatUserController.isLoggedIn) {
                        _chatUserController.logout();
                      } else {
                        Get.toNamed('/chatLogin');
                      }
                    },
                  ),
                ],
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                  'https://i2.hdslb.com/bfs/face/65d26cc9e6a628d38edc672f73d4652e6919e6f3.jpg'),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (_chatController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _chatController.refreshGroups,
          child: ListView.builder(
            itemCount: _chatController.groups.length,
            itemBuilder: (context, index) {
              final group = _chatController.groups[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    group.name.isNotEmpty ? group.name[0] : 'G',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(group.name),
                subtitle: Obx(() {
                  final formattedMessage = _chatController
                      .getFormattedLatestMessagePreview(group.gid);
                  final fallbackText =
                      group.description ?? '${group.members.length} 成员';

                  return Text(
                    formattedMessage.isNotEmpty
                        ? formattedMessage
                        : fallbackText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: formattedMessage.isNotEmpty
                          ? Colors.black87
                          : Colors.grey,
                      fontSize: formattedMessage.isNotEmpty ? 14 : 13,
                    ),
                  );
                }),
                trailing: Obx(() {
                  final latestTime =
                      _chatController.getLatestMessageTime(group.gid);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (latestTime.isNotEmpty)
                        Text(
                          latestTime,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (group.isPublic)
                            const Icon(Icons.public,
                                size: 14, color: Colors.green),
                          if (group.isPublic) const SizedBox(width: 4),
                          Text(
                            '${group.gid}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                onTap: () {
                  // 点击群组进入聊天
                  Get.toNamed('/chatRoom/${group.gid}');
                },
              );
            },
          ),
        );
      }),
    );
  }
}
