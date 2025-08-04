import 'package:get/get.dart';
import '../../apis/chat_apis/chat_apis.dart';
import '../../types/chat_types/chat_types.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find();

  final RxList<ChatGroup> groups = <ChatGroup>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
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
}
