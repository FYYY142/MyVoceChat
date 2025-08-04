import 'package:get/get.dart';
import '../../apis/chat_apis/chat_apis.dart';
import '../../types/chat_types/chat_types.dart';
import '../../utils/chat_http_util/chat_http_util.dart';
import 'chat_user_controller.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find();

  final RxList<ChatGroup> groups = <ChatGroup>[].obs;
  // 使用Map来存储每个群组的消息列表，key为群组ID，value为消息列表
  final RxMap<int, List<ChatMessage>> groupMessages =
      <int, List<ChatMessage>>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxInt currentGroupId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // 延迟初始化，等待ChatUserController加载完成
    Future.delayed(const Duration(milliseconds: 100), () {
      _initToken();
      loadGroups();
    });
  }

  void _initToken() {
    try {
      final chatUserController = Get.find<ChatUserController>();
      if (chatUserController.isLoggedIn &&
          chatUserController.token.isNotEmpty) {
        ChatHttpUtil.to.setToken(chatUserController.token);
      }
    } catch (e) {
      print('ChatUserController还未初始化完成: $e');
    }
  }

  /// 更新token（由ChatUserController调用）
  void updateToken() {
    _initToken();
  }

  Future<void> loadGroups() async {
    try {
      isLoading.value = true;
      final groupList = await ChatApis.getGroups();
      groups.value = groupList;

      // 群组加载完成后，预加载各群组的消息预览
      _preloadGroupPreviews();
    } catch (e) {
      print('加载群组失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 预加载各群组的消息预览（异步，不阻塞UI）
  Future<void> _preloadGroupPreviews() async {
    for (final group in groups) {
      // 如果该群组还没有加载过消息，则异步加载
      if (!groupMessages.containsKey(group.gid)) {
        // 使用Future.microtask避免阻塞UI
        Future.microtask(() => _loadGroupPreview(group.gid));
      }
    }
  }

  /// 加载单个群组的消息预览（静默加载，不显示loading状态）
  Future<void> _loadGroupPreview(int groupId) async {
    try {
      final messageList = await ChatApis.getGroupHistory(groupId);
      groupMessages[groupId] = messageList;
    } catch (e) {
      print('加载群组 $groupId 预览失败: $e');
      // 预览加载失败时，设置空列表避免重复请求
      groupMessages[groupId] = [];
    }
  }

  Future<void> refreshGroups() async {
    await loadGroups();
  }

  Future<void> loadGroupHistory(int groupId) async {
    try {
      isLoadingMessages.value = true;
      currentGroupId.value = groupId;
      final messageList = await ChatApis.getGroupHistory(groupId);
      // 将消息存储到对应群组的消息列表中
      groupMessages[groupId] = messageList;
    } catch (e) {
      print('加载群组历史记录失败: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> refreshGroupHistory() async {
    if (currentGroupId.value > 0) {
      await loadGroupHistory(currentGroupId.value);
    }
  }

  /// 获取指定群组的消息列表（按时间排序）
  List<ChatMessage> getGroupMessages(int groupId) {
    final messages = groupMessages[groupId] ?? [];
    // 按创建时间排序（旧消息在前，新消息在后）
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  /// 获取当前群组的消息列表
  List<ChatMessage> getCurrentGroupMessages() {
    if (currentGroupId.value > 0) {
      return getGroupMessages(currentGroupId.value);
    }
    return [];
  }

  /// 获取指定群组的最新消息
  ChatMessage? getLatestMessage(int groupId) {
    final messages = groupMessages[groupId] ?? [];
    if (messages.isNotEmpty) {
      // 找到时间戳最大的消息（最新消息）
      ChatMessage latestMessage = messages.first;
      for (final message in messages) {
        if (message.createdAt > latestMessage.createdAt) {
          latestMessage = message;
        }
      }
      return latestMessage;
    }
    return null;
  }

  /// 获取指定群组的最新消息预览文本
  String getLatestMessagePreview(int groupId) {
    final latestMessage = getLatestMessage(groupId);
    if (latestMessage != null) {
      String content = latestMessage.detail.content;
      // 限制预览文本长度
      if (content.length > 30) {
        content = '${content.substring(0, 30)}...';
      }
      return content;
    }
    return '';
  }

  /// 获取指定群组的最新消息发送者信息
  String getLatestMessageSender(int groupId) {
    final latestMessage = getLatestMessage(groupId);
    if (latestMessage != null) {
      return '用户${latestMessage.fromUid}';
    }
    return '';
  }

  /// 获取格式化的最新消息预览（包含发送者）
  String getFormattedLatestMessagePreview(int groupId) {
    final latestMessage = getLatestMessage(groupId);
    if (latestMessage != null) {
      final sender = getLatestMessageSender(groupId);
      final content = getLatestMessagePreview(groupId);
      return '$sender: $content';
    }
    return '';
  }

  /// 获取指定群组的最新消息时间
  String getLatestMessageTime(int groupId) {
    final latestMessage = getLatestMessage(groupId);
    if (latestMessage != null) {
      return formatMessageTime(latestMessage.createdAt);
    }
    return '';
  }

  /// 添加新消息到指定群组
  void addMessageToGroup(int groupId, ChatMessage message) {
    if (groupMessages.containsKey(groupId)) {
      groupMessages[groupId]!.add(message);
    } else {
      groupMessages[groupId] = [message];
    }
    // 触发UI更新
    groupMessages.refresh();
  }

  /// 清空指定群组的消息
  void clearGroupMessages(int groupId) {
    groupMessages.remove(groupId);
  }

  /// 清空所有群组的消息
  void clearAllMessages() {
    groupMessages.clear();
  }

  /// 获取群组消息数量
  int getGroupMessageCount(int groupId) {
    return getGroupMessages(groupId).length;
  }

  /// 检查群组是否有消息
  bool hasGroupMessages(int groupId) {
    return getGroupMessageCount(groupId) > 0;
  }

  /// 获取所有有消息的群组ID列表
  List<int> getGroupsWithMessages() {
    return groupMessages.keys
        .where((groupId) => hasGroupMessages(groupId))
        .toList();
  }

  /// 强制刷新指定群组的消息显示
  void refreshGroupMessagesDisplay(int groupId) {
    if (groupMessages.containsKey(groupId)) {
      groupMessages.refresh();
    }
  }

  ChatGroup? getCurrentGroup() {
    if (currentGroupId.value > 0) {
      return groups
          .firstWhereOrNull((group) => group.gid == currentGroupId.value);
    }
    return null;
  }

  String formatMessageTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
