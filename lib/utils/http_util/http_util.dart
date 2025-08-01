import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

class HttpUtil {
  static final HttpUtil _instance = HttpUtil._internal();
  static HttpUtil get to => _instance;

  HttpUtil._internal();

  final _dio = Get.find<dio.Dio>();

  Future<dio.Response> get(String url, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(url, queryParameters: params);
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dio.Response> post(String url, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(url, data: data);
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dio.Response> put(String url, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(url, data: data);
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dio.Response> delete(String url) async {
    try {
      final response = await _dio.delete(url);
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }
}
