import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

import 'package:my_voce_chat/utils/http_util/http_util.dart'; // 用于JSON格式化

class NetworkSettingsView extends StatefulWidget {
  const NetworkSettingsView({super.key});

  @override
  State<NetworkSettingsView> createState() => _NetworkSettingsViewState();
}

class _NetworkSettingsViewState extends State<NetworkSettingsView> {
  bool _isLoading = false;
  String _responseMessage = '点击下方按钮开始请求...';
  String? _currentApiUrl;

  // API 地址
  static const String _apiDailyQuote =
      'https://fyyy-express.vercel.app/api/daily-quote';
  static const String _apiOne = 'https://api.xygeng.cn/one';

  // 请求数据的方法
  Future<void> _fetchData(String url) async {
    setState(() {
      _isLoading = true;
      _responseMessage = '请求中...';
      _currentApiUrl = url;
    });

    try {
      final response = await HttpUtil.to.get(url);

      // 格式化响应体，如果是JSON则美化输出
      String formattedBody;
      try {
        if (response.data is Map || response.data is List) {
          formattedBody =
              const JsonEncoder.withIndent('  ').convert(response.data);
        } else {
          formattedBody = response.data.toString();
        }
      } catch (e) {
        formattedBody = response.data.toString(); // 如果不是有效JSON，则直接转字符串
      }

      setState(() {
        _responseMessage = '''
请求URL: $_currentApiUrl
请求状态: 成功
HTTP状态码: ${response.statusCode}
响应头:
${_formatHeaders(response.headers)}
响应体:
$formattedBody
        ''';
      });
    } catch (e) {
      setState(() {
        _responseMessage = '''
请求URL: $_currentApiUrl
请求状态: 失败
错误信息: ${e.toString()}
        ''';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 格式化响应头
  String _formatHeaders(dio.Headers headers) {
    return headers.map.entries.map((entry) {
      return '  ${entry.key}: ${entry.value.join(', ')}';
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          '网络设置',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 请求按钮
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _fetchData(_apiDailyQuote),
              icon: const Icon(Icons.cloud_download),
              label: const Text('请求每日一句 (Vercel)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 按钮背景色
                foregroundColor: Colors.white, // 按钮文字颜色
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _fetchData(_apiOne),
              icon: const Icon(Icons.cloud_download),
              label: const Text('请求一言 (xygeng.cn)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // 按钮背景色
                foregroundColor: Colors.white, // 按钮文字颜色
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 加载指示器
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 10),

            // 响应信息显示区域
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _responseMessage,
                    style: const TextStyle(
                      fontFamily: 'monospace', // 使用等宽字体，方便查看代码和JSON
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
