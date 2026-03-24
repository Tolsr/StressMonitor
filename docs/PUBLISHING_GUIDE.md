# 压力监控 App 发布指南

本文档详细说明如何将压力监控 App 发布到 GitHub 和 App Store。

---

## 第一部分：发布到 GitHub

### 步骤 1：创建 GitHub 仓库

1. 登录 [GitHub](https://github.com)
2. 点击右上角 **+** → **New repository**
3. 填写仓库信息：
   - **Repository name**: `StressMonitor`
   - **Description**: `一个优雅的 macOS 状态栏应用，帮助你监控工作压力`
   - **Visibility**: Public（开源）或 Private（私有）
4. **不要**勾选 "Add a README file"（我们已经有了）
5. 点击 **Create repository**

### 步骤 2：初始化本地仓库并推送

```bash
# 进入项目目录
cd /Users/tollyzhong/WorkBuddy/20260316112526/StressMonitorApp

# 初始化 Git 仓库
git init

# 添加所有文件
git add .

# 首次提交
git commit -m "Initial commit: Stress Monitor v1.0.0"

# 添加远程仓库（替换为你的用户名）
git remote add origin https://github.com/YOUR_USERNAME/StressMonitor.git

# 推送到 GitHub
git branch -M main
git push -u origin main
```

### 步骤 3：创建 Release

1. 在 GitHub 仓库页面，点击右侧 **Releases** → **Create a new release**
2. 点击 **Choose a tag**，输入 `v1.0.0`，选择 **Create new tag**
3. **Release title**: `v1.0.0 - 首次发布`
4. **描述**: 复制 CHANGELOG.md 中的 1.0.0 版本内容
5. **附件**: 上传编译好的 DMG 或 ZIP 文件

#### 创建 DMG 安装包

```bash
# 创建临时目录
mkdir -p /tmp/StressMonitor-dmg

# 复制应用
cp -R /Applications/StressMonitor.app /tmp/StressMonitor-dmg/

# 创建 Applications 链接
ln -s /Applications /tmp/StressMonitor-dmg/Applications

# 创建 DMG
hdiutil create -volname "StressMonitor" \
    -srcfolder /tmp/StressMonitor-dmg \
    -ov -format UDZO \
    ~/Desktop/StressMonitor-v1.0.0.dmg

# 清理
rm -rf /tmp/StressMonitor-dmg
```

### 步骤 4：完善 GitHub 仓库

1. **添加 Topics**（标签）：`macos`, `swift`, `swiftui`, `menubar`, `productivity`, `stress-management`
2. **设置 About**：添加描述和网站链接
3. **添加截图**：将应用截图上传到 `docs/images/` 目录

---

## 第二部分：发布到 App Store

### 前置条件

| 要求 | 说明 |
|------|------|
| Apple Developer Program | 需要注册，费用 $99/年 |
| Xcode | 最新版本 |
| 有效的 Apple ID | 用于登录 App Store Connect |
| Mac 设备 | 用于签名和上传 |

### 步骤 1：注册 Apple Developer Program

1. 访问 [Apple Developer Program](https://developer.apple.com/programs/)
2. 点击 **Enroll**
3. 使用 Apple ID 登录
4. 选择个人或组织账户类型
5. 支付 $99 年费

### 步骤 2：创建 App ID 和证书

#### 2.1 创建 App ID

1. 登录 [Apple Developer Portal](https://developer.apple.com/account)
2. 点击 **Certificates, Identifiers & Profiles**
3. 选择 **Identifiers** → **+** 按钮
4. 选择 **App IDs** → **Continue**
5. 选择 **App** → **Continue**
6. 填写信息：
   - **Description**: `Stress Monitor`
   - **Bundle ID**: `com.yourcompany.stressmonitor`
7. 点击 **Continue** → **Register**

#### 2.2 创建发布证书

1. 在 **Certificates** 页面，点击 **+**
2. 选择 **Apple Distribution** → **Continue**
3. 创建 Certificate Signing Request (CSR)：
   - 打开 **钥匙串访问** → **证书助理** → **从证书颁发机构请求证书**
   - 填写邮箱和名称，保存到本地
4. 上传 CSR 文件
5. 下载证书并双击安装

#### 2.3 创建 Provisioning Profile

1. 在 **Profiles** 页面，点击 **+**
2. 选择 **Mac App Store** → **Continue**
3. 选择你的 App ID → **Continue**
4. 选择证书 → **Continue**
5. 命名并下载 Profile

### 步骤 3：配置 Xcode 项目

#### 3.1 设置签名

1. 打开 `StressMonitor.xcodeproj`
2. 选择项目 → **Signing & Capabilities**
3. 勾选 **Automatically manage signing**
4. 选择你的 **Team**
5. 确保 **Bundle Identifier** 与 App ID 一致

#### 3.2 添加沙盒 (Sandbox)

1. 在 **Signing & Capabilities** 中，点击 **+ Capability**
2. 添加 **App Sandbox**
3. 配置必要的权限（参考 `StressMonitor.entitlements`）

#### 3.3 设置版本号

1. 选择项目 → **General**
2. 设置 **Version**: `1.0.0`
3. 设置 **Build**: `1`

### 步骤 4：在 App Store Connect 创建 App

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 点击 **我的 App** → **+** → **新建 App**
3. 填写信息：

| 字段 | 值 |
|------|-----|
| 平台 | macOS |
| 名称 | 压力监控 |
| 主要语言 | 简体中文 |
| 套装 ID | 选择你创建的 App ID |
| SKU | `stressmonitor001` |
| 用户访问权限 | 完全访问权限 |

### 步骤 5：准备 App Store 素材

#### 5.1 应用图标

需要提供以下尺寸的图标（PNG 格式，无透明度）：

| 尺寸 | 用途 |
|------|------|
| 1024 x 1024 | App Store |
| 512 x 512 | macOS 应用图标 |
| 256 x 256 | macOS 应用图标 |
| 128 x 128 | macOS 应用图标 |
| 64 x 64 | macOS 应用图标 |
| 32 x 32 | macOS 应用图标 |
| 16 x 16 | macOS 应用图标 |

#### 5.2 应用截图

macOS App Store 需要以下截图：

| 显示器类型 | 尺寸 |
|-----------|------|
| MacBook Pro 16" | 3456 x 2234 像素 |
| MacBook Pro 14" | 3024 x 1964 像素 |
| iMac 27" | 2880 x 1800 像素 |

**提示**：至少需要 1 张截图，建议提供 3-5 张展示不同功能。

#### 5.3 应用描述

```
压力监控是一款优雅的 macOS 状态栏应用，帮助你追踪工作与娱乐时间的平衡，管理日常压力。

功能特性：
• 状态栏常驻显示压力等级表情
• 智能识别工作和娱乐应用
• 自定义任意应用的分类
• 实时压力等级计算
• 减压功能，点击表情放松心情

压力等级：
😊 状态极佳 - 工作占比 < 30%
🙂 正常状态 - 工作占比 30-50%
😐 适度压力 - 工作占比 50-70%
😓 压力较高 - 工作占比 70-85%
😰 压力过载 - 工作占比 > 85%

隐私保护：
• 所有数据存储在本地
• 不收集任何个人信息
• 不上传数据到服务器
```

#### 5.4 关键词

```
压力,监控,工作,生活,平衡,效率,时间管理,状态栏,菜单栏,stress,monitor,productivity
```

#### 5.5 支持 URL

需要提供：
- **隐私政策 URL**：上传 `PRIVACY_POLICY.md` 到 GitHub 或个人网站
- **支持 URL**：GitHub Issues 页面或支持邮箱

### 步骤 6：上传 App 到 App Store Connect

#### 6.1 创建 Archive

1. 在 Xcode 中，选择 **Product** → **Archive**
2. 等待编译完成
3. 在 **Organizer** 窗口中看到新的 Archive

#### 6.2 验证 App

1. 选择 Archive，点击 **Validate App**
2. 选择 **App Store Connect** 分发方式
3. 等待验证完成，修复任何错误

#### 6.3 上传 App

1. 验证通过后，点击 **Distribute App**
2. 选择 **App Store Connect** → **Upload**
3. 选择签名选项，点击 **Upload**
4. 等待上传完成

### 步骤 7：提交审核

1. 在 App Store Connect 中，等待构建版本处理完成
2. 在 **App Store** 标签页填写所有必要信息
3. 选择构建版本
4. 回答出口合规性问题
5. 点击 **提交以供审核**

### 审核时间

| 类型 | 预计时间 |
|------|---------|
| 首次提交 | 1-3 个工作日 |
| 更新版本 | 通常 24 小时内 |
| 加急审核 | 可申请，但不保证 |

### 常见被拒原因及解决方案

| 被拒原因 | 解决方案 |
|----------|---------|
| 崩溃或性能问题 | 充分测试后重新提交 |
| 缺少隐私政策 | 添加隐私政策 URL |
| 功能不完整 | 确保所有功能正常工作 |
| 沙盒权限过多 | 只申请必要的权限 |
| 截图不符合要求 | 使用正确尺寸的截图 |

---

## 附录：快速命令参考

### GitHub 发布

```bash
# 初始化并推送
cd /Users/tollyzhong/WorkBuddy/20260316112526/StressMonitorApp
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/StressMonitor.git
git push -u origin main

# 创建标签
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 创建 DMG
hdiutil create -volname "StressMonitor" -srcfolder /Applications/StressMonitor.app -ov -format UDZO ~/Desktop/StressMonitor.dmg
```

### App Store 发布

```bash
# 验证应用
xcrun altool --validate-app -f StressMonitor.pkg -t macos -u YOUR_APPLE_ID

# 上传应用
xcrun altool --upload-app -f StressMonitor.pkg -t macos -u YOUR_APPLE_ID
```

---

## 联系方式

如有问题，请通过以下方式联系：

- GitHub Issues: https://github.com/YOUR_USERNAME/StressMonitor/issues
- Email: your-email@example.com
