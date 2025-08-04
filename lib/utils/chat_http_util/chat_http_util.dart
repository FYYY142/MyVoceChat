import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../alert_util/alert_util.dart';

class ChatHttpUtil {
  static final ChatHttpUtil _instance = ChatHttpUtil._internal();
  static ChatHttpUtil get to => _instance;

  ChatHttpUtil._internal();

  final _dio = Get.find<dio.Dio>();

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  dio.Options _getOptions() {
    return dio.Options(
      headers: {
        if (_token != null) 'X-API-Key': _token,
      },
    );
  }

  Future<dio.Response> get(String url, {Map<String, dynamic>? params}) async {
    try {
      final response =
          await _dio.get(url, queryParameters: params, options: _getOptions());
      return response;
    } on dio.DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      AlertUtil.showErrorDialog(message: '网络请求失败: $e');
      rethrow;
    }
  }

  Future<dio.Response> post(String url,
      {Map<String, dynamic>? data, bool showErrorDialog = true}) async {
    try {
      final response = await _dio.post(url, data: data, options: _getOptions());
      return response;
    } on dio.DioException catch (e) {
      if (showErrorDialog) {
        _handleDioException(e);
      }
      rethrow;
    } catch (e) {
      if (showErrorDialog) {
        AlertUtil.showErrorDialog(message: '网络请求失败: $e');
      }
      rethrow;
    }
  }

  Future<dio.Response> put(String url, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(url, data: data, options: _getOptions());
      return response;
    } on dio.DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      AlertUtil.showErrorDialog(message: '网络请求失败: $e');
      rethrow;
    }
  }

  Future<dio.Response> delete(String url) async {
    try {
      final response = await _dio.delete(url, options: _getOptions());
      return response;
    } on dio.DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      AlertUtil.showErrorDialog(message: '网络请求失败: $e');
      rethrow;
    }
  }

  void _handleDioException(dio.DioException e) {
    String message;
    switch (e.type) {
      case dio.DioExceptionType.connectionTimeout:
        message = '连接超时，请检查网络连接';
        break;
      case dio.DioExceptionType.sendTimeout:
        message = '发送超时，请检查网络连接';
        break;
      case dio.DioExceptionType.receiveTimeout:
        message = '接收超时，请检查网络连接';
        break;
      case dio.DioExceptionType.connectionError:
        message = '连接失败，请检查服务器地址和网络连接';
        break;
      case dio.DioExceptionType.badResponse:
        message = '服务器响应错误 (${e.response})';
        break;
      case dio.DioExceptionType.cancel:
        message = '请求已取消';
        break;
      case dio.DioExceptionType.unknown:
      default:
        message = '网络请求失败: ${e.message}';
        break;
    }
    AlertUtil.showErrorDialog(message: message);
  }
}
