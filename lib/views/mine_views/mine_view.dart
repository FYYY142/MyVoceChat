import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MineView extends StatefulWidget {
  const MineView({super.key});

  @override
  State<MineView> createState() => _MineViewState();
}

class _MineViewState extends State<MineView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 整体背景色，模仿iOS的浅灰色背景
      backgroundColor: const Color(0xFFF1F2F6),
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar背景为白色
        elevation: 0.5, // 稍微有一点阴影，但不要太重
        title: const Text(
          '我的',
          style: TextStyle(
            color: Colors.black, // 标题文字颜色
            fontWeight: FontWeight.w600, // 标题字体加粗
          ),
        ),
        centerTitle: true, // 标题居中
      ),
      body: ListView(
        children: [
          // 顶部个人信息区域
          Container(
            color: Colors.white, // 背景为白色
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            margin: const EdgeInsets.only(bottom: 10.0), // 底部留出一些间距
            child: Row(
              children: [
                // 用户头像
                CircleAvatar(
                  radius: 40, // 头像大小
                  backgroundImage: const NetworkImage(
                    'https://i2.hdslb.com/bfs/face/65d26cc9e6a628d38edc672f73d4652e6919e6f3.jpg',
                  ),
                  // 如果图片加载失败，显示一个默认图标
                  onBackgroundImageError: (exception, stackTrace) {
                    debugPrint('图片加载失败: $exception');
                  },
                ),
                const SizedBox(width: 15), // 头像和昵称之间的间距
                // 昵称
                const Text(
                  '枫亦有忆',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(), // 昵称和右侧箭头之间的弹性空间
                Icon(
                  Icons.arrow_forward_ios, // iOS风格的右箭头
                  color: Colors.grey[400],
                  size: 18,
                ),
              ],
            ),
          ),

          // 设置项列表
          _buildSettingsSection([
            _buildSettingsItem(
              icon: Icons.settings,
              title: '通用设置',
              onTap: () {
                // TODO: 实现通用设置页面跳转逻辑
                debugPrint('点击通用设置');
              },
            ),
            _buildSettingsItem(
              icon: Icons.notifications,
              title: '通知与隐私',
              onTap: () {
                // TODO: 实现通知与隐私页面跳转逻辑
                debugPrint('点击通知与隐私');
              },
            ),
          ]),

          const SizedBox(height: 10), // 间隔

          _buildSettingsSection([
            _buildSettingsItem(
              icon: Icons.wifi, // 网络设置图标
              title: '网络设置',
              onTap: () {
                // TODO: 实现网络设置页面跳转逻辑
                debugPrint('点击网络设置');
                Get.toNamed('/network');
              },
            ),
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: '帮助与反馈',
              onTap: () {
                // TODO: 实现帮助与反馈页面跳转逻辑
                debugPrint('点击帮助与反馈');
              },
            ),
          ]),

          const SizedBox(height: 10), // 间隔

          _buildSettingsSection([
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: '关于我们',
              onTap: () {
                // TODO: 实现关于我们页面跳转逻辑
                debugPrint('点击关于我们');
              },
            ),
          ]),
        ],
      ),
    );
  }

  // 构建单个设置项的Widget
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black54), // 左侧图标
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios, // 右侧箭头
            color: Colors.grey[400],
            size: 18,
          ),
          onTap: onTap, // 点击事件
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0), // 内容内边距
          dense: false, // 不使用紧凑模式，保持标准高度
        ),
        // 分隔线，除了最后一个item外都显示
        if (title != '关于我们') // 简单判断，实际应用中可能需要更灵活的判断
          Divider(
            height: 0.5,
            indent: 60, // 分隔线左侧缩进，与图标对齐
            endIndent: 0,
            color: Colors.grey[300],
          ),
      ],
    );
  }

  // 构建设置项的整体区域（带圆角和白色背景）
  Widget _buildSettingsSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0), // 左右无边距
      decoration: BoxDecoration(
        color: Colors.white, // 背景为白色
        borderRadius: BorderRadius.circular(10), // 圆角
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
