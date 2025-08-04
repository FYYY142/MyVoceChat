import '../../utils/http_util/http_util.dart';

/// 聊天用户相关API
class ChatUserApi {
  static const String _baseUrl = 'http://192.168.31.88:32768/api';
  static const String _magicToken =
      'db94a8671c0a4a01e514531e4ddea6fee8596680bee0b504e4dc5167e48c82a70000000000000600000000000000323638303335e7fab768000000000000';

  /// 用户登录
  /// [email] 邮箱
  /// [password] 密码
  /// 返回登录响应数据
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await HttpUtil.to.post(
        '$_baseUrl/token/login',
        data: {
          'credential': {
            'email': email,
            'password': password,
            'type': 'password',
          }
        },
        showErrorDialog: false,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// 用户注册
  /// [email] 邮箱
  /// [password] 密码
  /// 返回注册响应数据
  static Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await HttpUtil.to.post(
        '$_baseUrl/user/register',
        data: {
          'magic_token': _magicToken,
          'email': email,
          'password': password,
        },
        showErrorDialog: false,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
