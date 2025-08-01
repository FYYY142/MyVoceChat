# 我的语音聊天应用

一个基于Flutter的语音聊天应用，具有完整的主题系统和现代化的UI设计。

## 功能特性

- ✨ 完整的主题系统（浅色/深色/跟随系统）
- 🎨 基于Material Design 3的现代化UI
- 🔄 主题切换和持久化存储
- 📱 响应式设计，适配多种屏幕尺寸
- 🎯 语义化颜色命名，便于维护和扩展

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── theme/                       # 主题系统
│   ├── app_colors.dart         # 颜色定义
│   ├── app_theme.dart          # 主题配置
│   ├── theme_provider.dart     # 主题状态管理
│   ├── theme_extensions.dart   # 主题扩展方法
│   ├── theme_usage_examples.dart # 使用示例
│   └── README.md               # 主题系统说明
└── views/                       # 页面组件
    ├── home_page.dart          # 主页
    └── theme_demo_page.dart    # 主题演示页
```

## 主题系统

### 核心特性

- **主品牌色**: `#5FB1F0` - 清新的蓝色调
- **完整的颜色体系**: 包含主色、状态色、容器色等
- **语义化命名**: 如 `success`、`warning`、`cardBackground` 等
- **自动适配**: 深色模式下自动调整颜色对比度
- **便捷访问**: 通过 `context.colors.xxx` 快速访问

### 使用方法

```dart
// 获取当前主题颜色
Container(
  color: context.colors.cardBackground,
  child: Text(
    'Hello World',
    style: TextStyle(color: context.colors.onSurface),
  ),
)

// 判断当前主题模式
if (context.isDarkMode) {
  // 深色模式特定逻辑
}

// 切换主题
Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
```

## 开始使用

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 运行应用

```bash
flutter run
```

### 3. 查看主题演示

在应用中点击"主题演示"按钮，查看完整的主题系统展示。

## 依赖包

- `provider: ^6.1.2` - 状态管理
- `shared_preferences: ^2.2.3` - 本地存储

## 开发指南

### 添加新页面

1. 在 `lib/views/` 目录下创建新的页面文件
2. 使用 `context.colors` 访问主题颜色
3. 遵循Material Design 3设计规范

### 扩展主题

1. 在 `app_colors.dart` 中添加新颜色
2. 在 `theme_extensions.dart` 中添加访问方法
3. 确保浅色和深色模式都有对应的颜色定义

### 最佳实践

- 优先使用语义化颜色名称
- 在浅色和深色模式下都测试UI效果
- 使用 `Consumer` 只在需要的地方监听主题变化
- 遵循Material Design的设计原则

## 贡献

欢迎提交Issue和Pull Request来改进这个项目！

## 许可证

MIT License
