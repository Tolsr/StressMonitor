# StressMonitor 压力监控

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2012.0+-blue" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.0-orange" alt="Swift">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/version-2.0.1-brightgreen" alt="Version">
</p>

一个原生 macOS 状态栏应用，用于监控你的工作与娱乐时间比例，帮助你管理工作压力。

## ✨ 功能特性

- 🖥️ **状态栏常驻** - 以表情图标形式显示在 Mac 状态栏
- 📊 **智能分类** - 自动识别应用属于工作还是娱乐
- ✏️ **自定义分类** - 支持手动修改任意应用的分类
- 😊 **压力等级** - 根据工作/娱乐比例计算压力状态
- 🧘 **减压功能** - 点击表情可以减压
- 📅 **状态日历** - 查看历史每日工作状态记录
- 🪟 **三级交互窗口** - 简洁的悬浮窗口，支持展开查看详情

## 📸 截图

悬浮窗口支持三级交互：
1. **收起状态** - 仅显示表情和总时长
2. **展开状态** - 显示工作/娱乐时间比例
3. **应用列表** - 点击展开查看今日应用使用详情

## 🎭 压力等级

| 状态 | 工作占比 | 表情 | 说明 |
|------|---------|------|------|
| Excellent | < 30% | 😊 | 工作轻松，状态极佳 |
| Normal | 30-50% | 🙂 | 工作适中，保持良好 |
| Moderate | 50-70% | 😐 | 压力适中，注意休息 |
| High | 70-85% | 😓 | 压力较大，建议放松 |
| Overload | > 85% | 😰 | 压力过载，需要休息 |

## 📱 预设应用分类

### 💼 工作应用
- 企业微信、Safari、Chrome、Edge、Firefox
- 邮件、Outlook、Word、Excel、PowerPoint
- Figma、Notion、Slack、Zoom、腾讯会议
- Xcode、VS Code、Terminal、iTerm2

### 🎮 娱乐应用
- 微信、QQ、音乐、Spotify、网易云音乐
- 哔哩哔哩、腾讯视频、优酷、爱奇艺
- Steam、Epic Games
- 微博、知乎、豆瓣

## 📥 安装方法

### 方法一：下载 Release

1. 前往 [Releases](../../releases) 页面
2. 下载最新版本的 `StressMonitor-v2.0.0.dmg`
3. 打开 DMG 并将应用拖入 Applications 文件夹
4. 首次运行时，右键点击应用选择"打开"

### 方法二：使用 Xcode 编译

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/StressMonitor.git
cd StressMonitor

# 打开 Xcode 项目
open StressMonitor.xcodeproj
```

然后在 Xcode 中选择 **Product → Build** (⌘B)

### 方法三：命令行编译

```bash
# 编译 Release 版本
xcodebuild -project StressMonitor.xcodeproj \
    -scheme StressMonitor \
    -configuration Release \
    -derivedDataPath build \
    build

# 编译后的 App 在 build/Build/Products/Release/ 目录
```

## 🚀 使用说明

1. **启动应用** - 双击 StressMonitor.app，图标会出现在状态栏
2. **查看状态** - 点击状态栏图标打开悬浮窗口
3. **展开详情** - 点击箭头展开查看工作/娱乐比例
4. **查看应用** - 点击"今日应用"展开应用列表
5. **修改分类** - 点击应用右侧的分类标签即可切换
6. **减压** - 点击表情可以减压

## 🏗️ 技术架构

- **语言**: Swift 5
- **UI框架**: SwiftUI
- **最低系统**: macOS 12.0
- **应用类型**: 状态栏应用（无 Dock 图标）

## 📁 项目结构

```
StressMonitor/
├── StressMonitor.xcodeproj/    # Xcode 项目文件
├── StressMonitorSource/
│   ├── StressMonitorApp.swift  # 应用入口 & 悬浮窗口管理
│   ├── StressMonitor.swift     # 核心监控逻辑
│   └── MainView.swift          # UI 界面
├── build.sh                    # 编译脚本
└── README.md                   # 说明文档
```

## 💾 数据存储

所有数据保存在 UserDefaults 中：
- `customCategories` - 用户自定义的应用分类
- `appUsageRecords` - 应用使用记录
- `workTime` / `entertainmentTime` - 今日统计时间
- `stressReliefClicks` - 减压点击次数
- `statusCalendar` - 历史状态日历

每天零点自动重置当日统计数据。

## 🔒 隐私说明

- 本应用仅读取当前活跃应用的名称和 Bundle ID
- 所有数据均存储在本地，不上传到任何服务器
- 不记录应用内的具体操作或内容

## 📝 更新日志

### v2.0.0 (2026-03-25)
- ✨ 新增三级交互悬浮窗口设计
- ✨ 新增状态日历功能
- 🎨 优化展开/收起动画效果
- 🐛 修复动画闪烁问题
- 💄 改进 UI 视觉效果

### v1.0.0
- 🎉 首次发布
- 基础的压力监控功能
- 应用分类和统计

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件
