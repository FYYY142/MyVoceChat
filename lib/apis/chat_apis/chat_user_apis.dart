import 'package:my_voce_chat/utils/chat_http_util/chat_http_util.dart';

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
      final response = await ChatHttpUtil.to.post(
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
      final response = await ChatHttpUtil.to.post(
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

  /// 刷新Token
  /// [token] 当前访问token
  /// [refreshToken] 刷新token
  /// 返回新的token信息
  static Future<Map<String, dynamic>?> renewToken({
    required String token,
    required String refreshToken,
  }) async {
    try {
      final response = await ChatHttpUtil.to.post(
        '$_baseUrl/token/renew',
        data: {
          'token': token,
          'refresh_token': refreshToken,
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

  /// 退出登录
  /// 返回是否成功退出
  static Future<bool> logout() async {
    try {
      final response = await ChatHttpUtil.to.get('$_baseUrl/token/logout');

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}
