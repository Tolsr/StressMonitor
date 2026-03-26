# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.1] - 2026-03-25

### Changed
- 代码模块化重构，分为四个清晰的功能层：
  - **A. 氛围状态展示层 (StatusDisplayLayer)**: 表情大图、状态名称、减压交互
  - **B. 工作娱乐计时层 (WorkEntertainmentLayer)**: 时间统计、进度条比例
  - **C. 状态日历层 (CalendarLayer)**: 日历入口、历史记录弹窗
  - **D. 今日应用层 (AppListLayer)**: 应用列表、分类切换
- 提升代码可读性和可维护性
- 添加详细的代码注释和模块说明

## [2.0.0] - 2026-03-25

### Added
- 三级交互悬浮窗口设计
- 状态日历功能，查看历史每日工作状态
- 今日应用列表展开/收起功能
- 应用列表支持点击切换分类

### Changed
- 重构窗口展开逻辑，使用统一的动画配置
- 优化窗口宽度动态调整 (200px/300px/340px)
- 改进 UI 视觉效果和交互体验

### Fixed
- 修复窗口展开/收起动画闪烁问题
- 使用 easeInOut 动画替代 spring 动画
- 添加 clipped() 防止内容溢出

## [1.0.0] - 2026-03-23

### Added
- 状态栏常驻显示压力等级表情
- 实时监控当前活跃应用
- 智能分类工作/娱乐应用
- 自定义应用分类功能
- 压力等级计算（5 级）
- 减压功能（点击表情）
- 数据本地持久化
- 每日自动重置统计
- 深色/浅色模式支持

### Preset Categories
- **工作应用**: 企业微信、Safari、Chrome、Edge、Firefox、邮件、Outlook、Word、Excel、PowerPoint、Figma、Notion、Slack、Zoom、腾讯会议、Xcode、VS Code、Terminal、iTerm2
- **娱乐应用**: 微信、QQ、音乐、Spotify、网易云音乐、哔哩哔哩、腾讯视频、优酷、爱奇艺、Steam、Epic Games、微博、知乎、豆瓣

[Unreleased]: https://github.com/Tolsr/StressMonitor/compare/v2.0.1...HEAD
[2.0.1]: https://github.com/Tolsr/StressMonitor/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/Tolsr/StressMonitor/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/Tolsr/StressMonitor/releases/tag/v1.0.0
