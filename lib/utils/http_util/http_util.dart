import 'package:get/get.dart';
import 'package:dio/dio.dart';

class HttpUtil {
  static final HttpUtil _instance = HttpUtil._internal();
  static HttpUtil get to => _instance;

  HttpUtil._internal();

  final _dio = Get.find<Dio>();
}