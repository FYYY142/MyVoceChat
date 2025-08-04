import 'package:get/get.dart';
import '../../apis/chat_apis/chat_apis.dart';
import '../../types/chat_types/chat_types.dart';
import '../../utils/chat_http_util/chat_http_util.dart';
import 'chat_user_controller.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find();

  final RxList<ChatGroup> groups = <ChatGroup>[].obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
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
    } catch (e) {
      print('加载群组失败: $e');
    } finally {
      isLoading.value = false;
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
      messages.value = messageList;
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
