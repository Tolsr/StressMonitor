// StressMonitor.swift
// 核心监控逻辑

import Foundation
import AppKit
import Combine

// MARK: - 压力等级
enum StressLevel: String, CaseIterable {
    case excellent = "excellent"
    case normal = "normal"
    case moderate = "moderate"
    case high = "high"
    case overload = "overload"
    
    var emoji: String {
        switch self {
        case .excellent: return "😊"
        case .normal: return "🙂"
        case .moderate: return "😐"
        case .high: return "😓"
        case .overload: return "😰"
        }
    }
    
    var title: String {
        switch self {
        case .excellent: return "Excellent"
        case .normal: return "Normal"
        case .moderate: return "Moderate"
        case .high: return "High Stress"
        case .overload: return "Overload"
        }
    }
    
    var subtitle: String {
        switch self {
        case .excellent: return "心情愉悦！"
        case .normal: return "状态平衡"
        case .moderate: return "有点忙碌"
        case .high: return "需要休息"
        case .overload: return "压力过大！"
        }
    }
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .normal: return "lime"
        case .moderate: return "orange"
        case .high: return "red"
        case .overload: return "darkred"
        }
    }
}

// MARK: - 应用分类
enum AppCategory: String, Codable, CaseIterable {
    case work = "work"
    case entertainment = "entertainment"
    
    var displayName: String {
        switch self {
        case .work: return "工作"
        case .entertainment: return "娱乐"
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "💼"
        case .entertainment: return "🎮"
        }
    }
}

// MARK: - 应用使用记录
struct AppUsageRecord: Identifiable, Codable {
    let id: UUID
    let bundleId: String
    let appName: String
    var category: AppCategory
    var totalTime: TimeInterval // 秒
    var lastUsed: Date
    
    init(bundleId: String, appName: String, category: AppCategory) {
        self.id = UUID()
        self.bundleId = bundleId
        self.appName = appName
        self.category = category
        self.totalTime = 0
        self.lastUsed = Date()
    }
}

// MARK: - 压力监控器
class StressMonitor: ObservableObject {
    // 发布的属性
    @Published var currentLevel: StressLevel = .normal
    @Published var workTime: TimeInterval = 0
    @Published var entertainmentTime: TimeInterval = 0
    @Published var stressReliefClicks: Int = 0
    @Published var appUsageRecords: [String: AppUsageRecord] = [:]
    @Published var customCategories: [String: AppCategory] = [:]
    
    // 内部状态
    private var monitorTimer: Timer?
    private var lastActiveApp: String?
    private var lastCheckTime: Date?
    private var stressReductionBonus: Double = 0 // 减压加成
    
    var cancellables = Set<AnyCancellable>()
    
    // 预设分类
    private let defaultWorkApps: Set<String> = [
        "com.tencent.WeWorkMac",           // 企业微信
        "com.apple.Safari",                 // Safari
        "com.google.Chrome",                // Chrome
        "com.microsoft.edgemac",            // Edge
        "org.mozilla.firefox",              // Firefox
        "com.apple.mail",                   // 邮件
        "com.microsoft.Outlook",            // Outlook
        "com.microsoft.Word",               // Word
        "com.microsoft.Excel",              // Excel
        "com.microsoft.Powerpoint",         // PowerPoint
        "com.apple.iWork.Pages",            // Pages
        "com.apple.iWork.Numbers",          // Numbers
        "com.apple.iWork.Keynote",          // Keynote
        "com.figma.Desktop",                // Figma
        "com.notion.id",                    // Notion
        "com.electron.slack",               // Slack
        "us.zoom.xos",                      // Zoom
        "com.microsoft.teams",              // Teams
        "com.tencent.meeting",              // 腾讯会议
        "com.apple.dt.Xcode",               // Xcode
        "com.microsoft.VSCode",             // VS Code
        "com.jetbrains.intellij",           // IntelliJ
        "com.sublimetext.4",                // Sublime Text
        "com.googlecode.iterm2",            // iTerm2
        "com.apple.Terminal",               // Terminal
    ]
    
    private let defaultEntertainmentApps: Set<String> = [
        "com.tencent.xinWeChat",            // 微信
        "com.apple.Music",                  // 音乐
        "com.spotify.client",               // Spotify
        "com.netease.163music",             // 网易云音乐
        "tv.bilibili.player.mac",           // 哔哩哔哩
        "com.apple.TV",                     // Apple TV
        "com.netflix.Netflix",              // Netflix
        "com.tencent.tenvideo",             // 腾讯视频
        "com.youku.mac",                    // 优酷
        "com.iqiyi.player.mac",             // 爱奇艺
        "com.valvesoftware.steam",          // Steam
        "com.epicgames.EpicGamesLauncher",  // Epic Games
        "com.twitter.twitter-mac",          // Twitter
        "com.facebook.Facebook",            // Facebook
        "com.instagram.Instagram",          // Instagram
        "com.tencent.qq",                   // QQ
        "com.sina.weibo",                   // 微博
        "com.reddit.Reddit",                // Reddit
        "com.zhihu.mac",                    // 知乎
        "com.douban.Douban",                // 豆瓣
    ]
    
    init() {
        loadData()
    }
    
    // MARK: - 数据持久化
    private func loadData() {
        let defaults = UserDefaults.standard
        
        // 加载自定义分类
        if let data = defaults.data(forKey: "customCategories"),
           let categories = try? JSONDecoder().decode([String: AppCategory].self, from: data) {
            customCategories = categories
        }
        
        // 加载使用记录
        if let data = defaults.data(forKey: "appUsageRecords"),
           let records = try? JSONDecoder().decode([String: AppUsageRecord].self, from: data) {
            appUsageRecords = records
        }
        
        // 加载今日统计（检查日期）
        let today = Calendar.current.startOfDay(for: Date())
        if let savedDate = defaults.object(forKey: "lastResetDate") as? Date,
           Calendar.current.isDate(savedDate, inSameDayAs: today) {
            workTime = defaults.double(forKey: "workTime")
            entertainmentTime = defaults.double(forKey: "entertainmentTime")
            stressReliefClicks = defaults.integer(forKey: "stressReliefClicks")
        } else {
            // 新的一天，重置统计
            resetDailyStats()
            defaults.set(today, forKey: "lastResetDate")
        }
    }
    
    private func saveData() {
        let defaults = UserDefaults.standard
        
        if let data = try? JSONEncoder().encode(customCategories) {
            defaults.set(data, forKey: "customCategories")
        }
        
        if let data = try? JSONEncoder().encode(appUsageRecords) {
            defaults.set(data, forKey: "appUsageRecords")
        }
        
        defaults.set(workTime, forKey: "workTime")
        defaults.set(entertainmentTime, forKey: "entertainmentTime")
        defaults.set(stressReliefClicks, forKey: "stressReliefClicks")
    }
    
    func resetDailyStats() {
        workTime = 0
        entertainmentTime = 0
        stressReliefClicks = 0
        stressReductionBonus = 0
        
        // 重置每个应用的今日时间
        for key in appUsageRecords.keys {
            appUsageRecords[key]?.totalTime = 0
        }
        
        saveData()
    }
    
    // MARK: - 监控逻辑
    func startMonitoring() {
        lastCheckTime = Date()
        
        // 每秒检查一次当前活跃应用
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkActiveApp()
        }
    }
    
    func stopMonitoring() {
        monitorTimer?.invalidate()
        monitorTimer = nil
        saveData()
    }
    
    private func checkActiveApp() {
        guard let activeApp = NSWorkspace.shared.frontmostApplication,
              let bundleId = activeApp.bundleIdentifier,
              let appName = activeApp.localizedName else {
            return
        }
        
        let now = Date()
        let elapsed: TimeInterval
        
        if let lastTime = lastCheckTime {
            elapsed = now.timeIntervalSince(lastTime)
        } else {
            elapsed = 1.0
        }
        
        lastCheckTime = now
        
        // 更新应用使用记录
        updateAppUsage(bundleId: bundleId, appName: appName, elapsed: elapsed)
        
        // 获取分类并更新时间
        let category = getCategory(for: bundleId)
        
        if category == .work {
            workTime += elapsed
        } else {
            entertainmentTime += elapsed
        }
        
        // 计算压力等级
        updateStressLevel()
        
        // 定期保存
        if Int(workTime + entertainmentTime) % 30 == 0 {
            saveData()
        }
    }
    
    private func updateAppUsage(bundleId: String, appName: String, elapsed: TimeInterval) {
        if var record = appUsageRecords[bundleId] {
            record.totalTime += elapsed
            record.lastUsed = Date()
            appUsageRecords[bundleId] = record
        } else {
            let category = getCategory(for: bundleId)
            var newRecord = AppUsageRecord(bundleId: bundleId, appName: appName, category: category)
            newRecord.totalTime = elapsed
            appUsageRecords[bundleId] = newRecord
        }
    }
    
    func getCategory(for bundleId: String) -> AppCategory {
        // 优先使用用户自定义
        if let custom = customCategories[bundleId] {
            return custom
        }
        
        // 使用预设分类
        if defaultWorkApps.contains(bundleId) {
            return .work
        }
        
        if defaultEntertainmentApps.contains(bundleId) {
            return .entertainment
        }
        
        // 默认为娱乐
        return .entertainment
    }
    
    func setCategory(for bundleId: String, category: AppCategory) {
        customCategories[bundleId] = category
        
        // 更新记录中的分类
        if var record = appUsageRecords[bundleId] {
            record.category = category
            appUsageRecords[bundleId] = record
        }
        
        saveData()
    }
    
    private func updateStressLevel() {
        let totalTime = workTime + entertainmentTime
        let fiveMinutes: TimeInterval = 5 * 60
        
        // 总时间不足 5 分钟，默认 normal
        if totalTime < fiveMinutes {
            currentLevel = .normal
            return
        }
        
        // 计算工作时间占比（考虑减压加成）
        var workRatio = workTime / totalTime
        workRatio = max(0, workRatio - stressReductionBonus)
        
        // 根据工作占比判断状态
        if workRatio < 0.3 {
            currentLevel = .excellent
        } else if workRatio < 0.5 {
            currentLevel = .normal
        } else if workRatio < 0.7 {
            currentLevel = .moderate
        } else if workRatio < 0.85 {
            currentLevel = .high
        } else {
            currentLevel = .overload
        }
    }
    
    // MARK: - 减压功能
    func performStressRelief() -> Bool {
        stressReliefClicks += 1
        
        // 每 10 次点击减少 5% 压力（最多 30%）
        if stressReliefClicks % 10 == 0 && stressReductionBonus < 0.3 {
            stressReductionBonus += 0.05
            updateStressLevel()
            saveData()
            return true // 达到阈值
        }
        
        saveData()
        return false
    }
    
    // MARK: - 获取排序后的应用列表
    func getSortedAppRecords() -> [AppUsageRecord] {
        return appUsageRecords.values
            .sorted { $0.totalTime > $1.totalTime }
    }
}
