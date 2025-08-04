import '../../utils/chat_http_util/chat_http_util.dart';
import '../../types/chat_types/chat_types.dart';

class ChatApis {
  static const String _baseUrl = 'http://192.168.31.88:32768/api';
  static final ChatHttpUtil _httpUtil = ChatHttpUtil.to;

  static Future<List<ChatGroup>> getGroups() async {
    final response = await _httpUtil.get('$_baseUrl/group');
    final List<dynamic> data = response.data;
    return data.map((json) => ChatGroup.fromJson(json)).toList();
  }
}
