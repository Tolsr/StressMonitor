# 压力监控 (Stress Monitor)

<p align="center">
  <img src="docs/images/icon.png" alt="Stress Monitor Icon" width="128" height="128">
</p>

<p align="center">
  <strong>一个优雅的 macOS 状态栏应用，帮助你监控工作压力、平衡工作与生活</strong>
</p>

<p align="center">
  <a href="#功能特性">功能特性</a> •
  <a href="#安装方法">安装方法</a> •
  <a href="#使用说明">使用说明</a> •
  <a href="#开发">开发</a> •
  <a href="#许可证">许可证</a>
</p>

---

## 功能特性

- **🖥️ 状态栏常驻** - 以表情图标形式显示在 Mac 状态栏，一目了然
- **📊 智能分类** - 自动识别应用属于工作还是娱乐
- **✏️ 自定义分类** - 支持手动修改任意应用的分类
- **😊 压力等级** - 根据工作/娱乐比例实时计算压力状态
- **🧘 减压功能** - 点击表情可以减压，让心情更轻松
- **💾 数据持久化** - 自动保存设置，每天零点重置统计

## 截图

<p align="center">
  <img src="docs/images/screenshot-main.png" alt="Main View" width="320">
</p>

## 压力等级

| 状态 | 工作占比 | 表情 | 说明 |
|------|---------|------|------|
| Excellent | < 30% | 😊 | 状态极佳 |
| Normal | 30-50% | 🙂 | 正常状态 |
| Moderate | 50-70% | 😐 | 适度压力 |
| High | 70-85% | 😓 | 压力较高 |
| Overload | > 85% | 😰 | 压力过载 |

## 安装方法

### 方法一：下载预编译版本（推荐）

1. 前往 [Releases](https://github.com/YOUR_USERNAME/StressMonitor/releases) 页面
2. 下载最新版本的 `StressMonitor.dmg`
3. 打开 DMG 文件，将应用拖入 Applications 文件夹
4. 首次运行时，右键点击应用选择"打开"

### 方法二：使用 Homebrew（即将支持）

```bash
brew install --cask stress-monitor
```

### 方法三：从源码编译

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/StressMonitor.git
cd StressMonitor

# 使用 Xcode 编译
xcodebuild -project StressMonitor.xcodeproj \
    -scheme StressMonitor \
    -configuration Release \
    build

# 编译后的应用在 build/Build/Products/Release/StressMonitor.app
```

## 使用说明

### 基本操作

1. **启动应用** - 双击 StressMonitor.app，图标会出现在状态栏
2. **查看状态** - 点击状态栏图标打开详情面板
3. **修改分类** - 在应用列表中点击分类标签切换工作/娱乐
4. **减压** - 当压力等级较高时，点击表情可以减压

### 预设分类

**工作应用**
- 企业微信、Safari、Chrome、Edge、Firefox
- 邮件、Outlook、Word、Excel、PowerPoint
- Figma、Notion、Slack、Zoom、腾讯会议
- Xcode、VS Code、Terminal、iTerm2

**娱乐应用**
- 微信、QQ、音乐、Spotify、网易云音乐
- 哔哩哔哩、腾讯视频、优酷、爱奇艺
- Steam、Epic Games
- 微博、知乎、豆瓣

### 设置开机自启动

1. 打开 **系统设置 → 通用 → 登录项**
2. 点击 **+** 添加 StressMonitor.app

## 开发

### 环境要求

- macOS 12.0 或更高版本
- Xcode 14.0 或更高版本
- Swift 5.7 或更高版本

### 项目结构

```
StressMonitor/
├── StressMonitor.xcodeproj/    # Xcode 项目文件
├── Sources/
│   ├── StressMonitorApp.swift  # 应用入口
│   ├── StressMonitor.swift     # 核心监控逻辑
│   └── MainView.swift          # UI 界面
├── Resources/
│   ├── Assets.xcassets/        # 图标资源
│   └── Info.plist              # 应用配置
└── docs/                       # 文档和截图
```

### 本地开发

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/StressMonitor.git

# 打开项目
open StressMonitor.xcodeproj

# 在 Xcode 中按 ⌘R 运行
```

### 贡献指南

欢迎提交 Pull Request！请确保：

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 隐私说明

- 本应用仅读取当前活跃应用的名称和 Bundle ID
- 所有数据均存储在本地，不上传到任何服务器
- 不记录应用内的具体操作或内容

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 致谢

- 感谢所有贡献者的支持
- 图标设计灵感来源于 macOS 设计规范

---

<p align="center">
  如果这个项目对你有帮助，请给它一个 ⭐️
</p>
