// StressMonitor.swift
// 核心监控逻辑 v2.0 - 支持状态日历和每日重置

import Foundation
import AppKit
import Combine

// MARK: - 压力等级
enum StressLevel: String, CaseIterable, Codable {
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
    
    var color: NSColor {
        switch self {
        case .excellent: return NSColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        case .normal: return NSColor(red: 0.4, green: 0.8, blue: 0.2, alpha: 1.0)
        case .moderate: return NSColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        case .high: return NSColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        case .overload: return NSColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
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

// MARK: - 每日状态记录（用于状态日历）
struct DailyStatusRecord: Codable, Identifiable {
    var id: String { dateString }
    let dateString: String
    let date: Date
    let finalLevel: StressLevel
    let workTime: TimeInterval
    let entertainmentTime: TimeInterval
    let topApps: [String] // 前3个应用名称
    
    var totalTime: TimeInterval {
        workTime + entertainmentTime
    }
    
    var workRatio: Double {
        guard totalTime > 0 else { return 0 }
        return workTime / totalTime
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
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
    @Published var statusCalendar: [DailyStatusRecord] = [] // 状态日历（保留7天）
    
    // 内部状态
    private var monitorTimer: Timer?
    private var midnightTimer: Timer?
    private var lastActiveApp: String?
    private var lastCheckTime: Date?
    private var stressReductionBonus: Double = 0 // 减压加成
    private var currentDateString: String = ""
    
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
        currentDateString = getTodayString()
        loadData()
        setupMidnightReset()
    }
    
    // MARK: - 获取日期字符串
    private func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    // MARK: - 设置午夜重置定时器
    private func setupMidnightReset() {
        // 计算距离下一个午夜的时间
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) else {
            return
        }
        
        let interval = tomorrow.timeIntervalSinceNow
        
        // 设置定时器在午夜触发
        midnightTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.performMidnightReset()
        }
    }
    
    // MARK: - 午夜重置
    private func performMidnightReset() {
        // 保存今天的状态到日历
        saveTodayToCalendar()
        
        // 重置统计
        resetDailyStats()
        
        // 更新日期字符串
        currentDateString = getTodayString()
        
        // 重新设置午夜定时器
        setupMidnightReset()
    }
    
    // MARK: - 保存今日状态到日历
    private func saveTodayToCalendar() {
        // 获取前3个使用最多的应用
        let topApps = getSortedAppRecords()
            .prefix(3)
            .map { $0.appName }
        
        let record = DailyStatusRecord(
            dateString: currentDateString,
            date: Date(),
            finalLevel: currentLevel,
            workTime: workTime,
            entertainmentTime: entertainmentTime,
            topApps: Array(topApps)
        )
        
        // 添加到日历
        statusCalendar.append(record)
        
        // 只保留最近7天
        if statusCalendar.count > 7 {
            statusCalendar.removeFirst(statusCalendar.count - 7)
        }
        
        saveData()
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
        
        // 加载状态日历
        if let data = defaults.data(forKey: "statusCalendar"),
           let calendar = try? JSONDecoder().decode([DailyStatusRecord].self, from: data) {
            // 过滤只保留7天内的记录
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            statusCalendar = calendar.filter { $0.date > sevenDaysAgo }
        }
        
        // 加载今日统计（检查日期）
        let todayString = getTodayString()
        if let savedDateString = defaults.string(forKey: "lastResetDateString"),
           savedDateString == todayString {
            workTime = defaults.double(forKey: "workTime")
            entertainmentTime = defaults.double(forKey: "entertainmentTime")
            stressReliefClicks = defaults.integer(forKey: "stressReliefClicks")
            stressReductionBonus = defaults.double(forKey: "stressReductionBonus")
        } else {
            // 新的一天
            if defaults.string(forKey: "lastResetDateString") != nil {
                // 保存昨天的状态（如果有数据）
                if workTime > 0 || entertainmentTime > 0 {
                    saveTodayToCalendar()
                }
            }
            // 重置统计
            resetDailyStats()
            defaults.set(todayString, forKey: "lastResetDateString")
        }
        
        // 更新压力等级
        updateStressLevel()
    }
    
    private func saveData() {
        let defaults = UserDefaults.standard
        
        if let data = try? JSONEncoder().encode(customCategories) {
            defaults.set(data, forKey: "customCategories")
        }
        
        if let data = try? JSONEncoder().encode(appUsageRecords) {
            defaults.set(data, forKey: "appUsageRecords")
        }
        
        if let data = try? JSONEncoder().encode(statusCalendar) {
            defaults.set(data, forKey: "statusCalendar")
        }
        
        defaults.set(workTime, forKey: "workTime")
        defaults.set(entertainmentTime, forKey: "entertainmentTime")
        defaults.set(stressReliefClicks, forKey: "stressReliefClicks")
        defaults.set(stressReductionBonus, forKey: "stressReductionBonus")
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
        
        currentLevel = .normal
        saveData()
    }
    
    // MARK: - 监控逻辑
    func startMonitoring() {
        lastCheckTime = Date()
        
        // 检查是否需要重置（跨天启动的情况）
        let todayString = getTodayString()
        if todayString != currentDateString {
            performMidnightReset()
        }
        
        // 每秒检查一次当前活跃应用
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkActiveApp()
        }
    }
    
    func stopMonitoring() {
        monitorTimer?.invalidate()
        monitorTimer = nil
        midnightTimer?.invalidate()
        midnightTimer = nil
        saveData()
    }
    
    private func checkActiveApp() {
        // 检查是否跨天
        let todayString = getTodayString()
        if todayString != currentDateString {
            performMidnightReset()
        }
        
        guard let activeApp = NSWorkspace.shared.frontmostApplication,
              let bundleId = activeApp.bundleIdentifier,
              let appName = activeApp.localizedName else {
            return
        }
        
        let now = Date()
        let elapsed: TimeInterval
        
        if let lastTime = lastCheckTime {
            elapsed = min(now.timeIntervalSince(lastTime), 5.0) // 最大5秒，防止休眠后异常
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
        
        // 定期保存（每30秒）
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
        // 更新自定义分类
        customCategories[bundleId] = category
        
        // 更新记录中的分类，并触发 Published 更新
        if var record = appUsageRecords[bundleId] {
            let oldCategory = record.category
            record.category = category
            
            // 重新计算工作/娱乐时间
            if oldCategory != category {
                if category == .work {
                    // 从娱乐转为工作
                    workTime += record.totalTime
                    entertainmentTime -= record.totalTime
                } else {
                    // 从工作转为娱乐
                    entertainmentTime += record.totalTime
                    workTime -= record.totalTime
                }
                // 确保时间不为负
                workTime = max(0, workTime)
                entertainmentTime = max(0, entertainmentTime)
            }
            
            // 触发 appUsageRecords 更新
            appUsageRecords[bundleId] = record
        }
        
        // 更新压力等级
        updateStressLevel()
        
        saveData()
        
        // 强制触发 objectWillChange
        objectWillChange.send()
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
    
    // MARK: - 格式化时间
    func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
    
    // MARK: - 获取总使用时间
    var totalTime: TimeInterval {
        workTime + entertainmentTime
    }
    
    // MARK: - 获取工作占比
    var workRatio: Double {
        guard totalTime > 0 else { return 0 }
        return workTime / totalTime
    }
}
