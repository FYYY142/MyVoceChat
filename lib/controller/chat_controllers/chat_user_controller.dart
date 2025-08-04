import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_voce_chat/controller/chat_controllers/chat_controller.dart';
import 'package:my_voce_chat/utils/chat_http_util/chat_http_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:my_voce_chat/types/chat_types/chat_user_types.dart';
import '../../apis/chat_apis/chat_user_apis.dart';
import '../../utils/alert_util/alert_util.dart';

class ChatUserController extends GetxController {
  static ChatUserController get to => Get.find();

  late SharedPreferences _prefs;

  // 响应式状态
  final _isLoggedIn = false.obs;
  final _isLoading = false.obs;
  final _currentUser = Rxn<UserInfo>();
  final _token = ''.obs;
  final _refreshToken = ''.obs;
  final _serverId = ''.obs;

  // Getters
  bool get isLoggedIn => _isLoggedIn.value;
  bool get isLoading => _isLoading.value;
  UserInfo? get currentUser => _currentUser.value;
  String get token => _token.value;
  String get refreshToken => _refreshToken.value;
  String get serverId => _serverId.value;

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
  }

  /// 初始化 SharedPreferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadStoredUserData();
    // 通知其他控制器token已加载完成
    _notifyTokenLoaded();
  }

  /// 通知其他控制器token已加载完成
  void _notifyTokenLoaded() {
    // 如果ChatController已经初始化，通知它更新token
    try {
      final chatController = Get.find<ChatController>();
      chatController.updateToken();
    } catch (e) {
      // ChatController还没有初始化，这是正常的
    }
  }

  /// 从本地存储加载用户数据
  void _loadStoredUserData() {
    final storedToken = _prefs.getString('access_token');
    final storedRefreshToken = _prefs.getString('refresh_token');
    final storedServerId = _prefs.getString('server_id');
    final storedUserJson = _prefs.getString('user_info');

    if (storedToken != null && storedUserJson != null) {
      _token.value = storedToken;
      _refreshToken.value = storedRefreshToken ?? '';
      _serverId.value = storedServerId ?? '';

      // 为网络请求设置 token
      ChatHttpUtil.to.setToken(storedToken);

      try {
        final userMap = jsonDecode(storedUserJson);
        _currentUser.value = UserInfo.fromJson(userMap);
        _isLoggedIn.value = true;
      } catch (e) {
        print('解析用户信息失败: $e');
        // 如果解析失败，清除损坏的数据
        _clearStoredData();
      }
    }
  }

  /// 登录
  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;

      final data = await ChatUserApi.login(
        email: email,
        password: password,
      );

      if (data != null) {
        print('登录成功，准备保存数据: ${data.toString()}');
        await _saveUserData(data);
        print('数据保存完成，准备显示弹窗');

        Fluttertoast.showToast(
          msg: '登录成功',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        if (data['token'] != '') {
          ChatHttpUtil.to.setToken(data['token']);
        }

        // AlertUtil.showLogDialog(message: data.toString());
        return true;
      } else {
        AlertUtil.showErrorDialog(message: '登录失败，请检查用户名和密码');
        return false;
      }
    } catch (e) {
      AlertUtil.showErrorDialog(message: '登录失败: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 注册
  Future<bool> register(String email, String password) async {
    try {
      _isLoading.value = true;

      final data = await ChatUserApi.register(
        email: email,
        password: password,
      );

      if (data != null) {
        await _saveUserData(data);
        Fluttertoast.showToast(
          msg: '注册成功',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        // AlertUtil.showLogDialog(message: data.toString());
        return true;
      } else {
        AlertUtil.showErrorDialog(message: '注册失败，请检查输入信息');
        return false;
      }
    } catch (e) {
      AlertUtil.showErrorDialog(message: '注册失败: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 保存用户数据到本地
  Future<void> _saveUserData(Map<String, dynamic> data) async {
    _token.value = data['token'] ?? '';
    _refreshToken.value = data['refresh_token'] ?? '';
    _serverId.value = data['server_id'] ?? '';
    _currentUser.value = UserInfo.fromJson(data['user']);
    _isLoggedIn.value = true;

    // 为网络请求设置 token
    ChatHttpUtil.to.setToken(_token.value);

    // 保存到本地存储
    await _prefs.setString('access_token', _token.value);
    await _prefs.setString('refresh_token', _refreshToken.value);
    await _prefs.setString('server_id', _serverId.value);
    await _prefs.setString('user_info', jsonEncode(data['user']));
  }

  /// 登出
  Future<void> logout() async {
    // 清理本地数据
    _token.value = '';
    _refreshToken.value = '';
    _serverId.value = '';
    _currentUser.value = null;
    _isLoggedIn.value = false;

    await ChatUserApi.logout();

    await _clearStoredData();

    Fluttertoast.showToast(
      msg: '已退出登录',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  /// 清除存储的数据
  Future<void> _clearStoredData() async {
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
    await _prefs.remove('server_id');
    await _prefs.remove('user_info');
  }

  /// 刷新Token
  Future<bool> toRefreshToken() async {
    if (_token.value.isEmpty || _refreshToken.value.isEmpty) {
      print('Token或RefreshToken为空，无法刷新');
      return false;
    }

    try {
      _isLoading.value = true;

      final data = await ChatUserApi.renewToken(
        token: _token.value,
        refreshToken: _refreshToken.value,
      );

      if (data != null) {
        // 更新token信息
        _token.value = data['token'] ?? '';
        _refreshToken.value = data['refresh_token'] ?? '';

        // 保存到本地存储
        await _prefs.setString('access_token', _token.value);
        await _prefs.setString('refresh_token', _refreshToken.value);

        print('Token刷新成功');
        return true;
      } else {
        print('Token刷新失败，服务器返回空数据');
        return false;
      }
    } catch (e) {
      print('Token刷新失败: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 自动刷新Token（当token即将过期时调用）
  Future<bool> autoRefreshTokenIfNeeded() async {
    // 这里可以添加token过期时间检查逻辑
    // 如果token即将过期，自动调用refreshToken()
    return await toRefreshToken();
  }
}
