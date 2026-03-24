// MainView.swift
// 主界面视图

import SwiftUI

struct MainView: View {
    @EnvironmentObject var monitor: StressMonitor
    @State private var isAnimating = false
    @State private var showReliefEffect = false
    @State private var reliefText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部状态卡片
            StatusCardView(
                level: monitor.currentLevel,
                isAnimating: $isAnimating,
                showReliefEffect: $showReliefEffect,
                reliefText: $reliefText,
                onTap: handleFaceTap
            )
            
            // 统计信息
            StatsView(
                workTime: monitor.workTime,
                entertainmentTime: monitor.entertainmentTime,
                reliefClicks: monitor.stressReliefClicks
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // 应用列表
            AppListView()
                .environmentObject(monitor)
                .padding(.top, 12)
            
            Spacer()
        }
        .frame(width: 320, height: 480)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func handleFaceTap() {
        // 播放动画
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnimating = false
        }
        
        // 只有压力状态才能减压
        if monitor.currentLevel == .moderate || 
           monitor.currentLevel == .high || 
           monitor.currentLevel == .overload {
            let levelReduced = monitor.performStressRelief()
            
            showReliefEffect = true
            reliefText = levelReduced ? "压力 -10%!" : "压力 -1"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showReliefEffect = false
            }
        }
    }
}

// MARK: - 状态卡片
struct StatusCardView: View {
    let level: StressLevel
    @Binding var isAnimating: Bool
    @Binding var showReliefEffect: Bool
    @Binding var reliefText: String
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack {
                // 文字部分
                VStack(alignment: .leading, spacing: 4) {
                    Text(level == .excellent || level == .normal ? "MOOD LEVEL" : "STRESS LEVEL")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.5)
                        .opacity(0.8)
                    
                    Text(level.title)
                        .font(.system(size: 24, weight: .bold))
                    
                    Text(level.subtitle)
                        .font(.system(size: 12))
                        .opacity(0.85)
                }
                .foregroundColor(textColor)
                
                Spacer()
                
                // 表情
                ZStack {
                    Text(level.emoji)
                        .font(.system(size: 50))
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                    
                    // 减压效果
                    if showReliefEffect {
                        Text(reliefText)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(reliefText.contains("10%") ? .purple : .green)
                            .offset(y: -40)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .frame(width: 70, height: 70)
                .onTapGesture(perform: onTap)
                .cursor(canRelief ? .pointingHand : .arrow)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
    
    private var canRelief: Bool {
        level == .moderate || level == .high || level == .overload
    }
    
    private var gradientColors: [Color] {
        switch level {
        case .excellent:
            return [Color(hex: "6ee7b7"), Color(hex: "34d399")]
        case .normal:
            return [Color(hex: "bef264"), Color(hex: "84cc16")]
        case .moderate:
            return [Color(hex: "fdba74"), Color(hex: "f97316")]
        case .high:
            return [Color(hex: "fca5a5"), Color(hex: "ef4444")]
        case .overload:
            return [Color(hex: "f87171"), Color(hex: "991b1b")]
        }
    }
    
    private var textColor: Color {
        switch level {
        case .normal:
            return Color(hex: "1a1a1a")
        default:
            return .white
        }
    }
}

// MARK: - 统计视图
struct StatsView: View {
    let workTime: TimeInterval
    let entertainmentTime: TimeInterval
    let reliefClicks: Int
    
    var body: some View {
        HStack(spacing: 8) {
            StatCard(icon: "💼", label: "工作时间", value: formatTime(workTime), color: Color(hex: "dcfce7"))
            StatCard(icon: "🎮", label: "娱乐时间", value: formatTime(entertainmentTime), color: Color(hex: "fef3c7"))
            StatCard(icon: "🧘", label: "减压次数", value: "\(reliefClicks)", color: Color(hex: "e0e7ff"))
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        if seconds < 60 { return "\(Int(seconds))s" }
        if seconds < 3600 { return "\(Int(seconds / 60))m" }
        let hours = Int(seconds / 3600)
        let mins = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h\(mins)m"
    }
}

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 18))
            
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 应用列表
struct AppListView: View {
    @EnvironmentObject var monitor: StressMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("应用使用")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(monitor.getSortedAppRecords().prefix(10)) { record in
                        AppRowView(record: record) { newCategory in
                            monitor.setCategory(for: record.bundleId, category: newCategory)
                        }
                    }
                    
                    if monitor.appUsageRecords.isEmpty {
                        Text("暂无使用记录")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(maxHeight: 250)
        }
    }
}

struct AppRowView: View {
    let record: AppUsageRecord
    let onCategoryChange: (AppCategory) -> Void
    @State private var showDropdown = false
    
    var body: some View {
        HStack(spacing: 10) {
            // 应用图标
            if let icon = getAppIcon(bundleId: record.bundleId) {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
            }
            
            // 应用名和时间
            VStack(alignment: .leading, spacing: 2) {
                Text(record.appName)
                    .font(.system(size: 12))
                    .lineLimit(1)
                
                Text(formatTime(record.totalTime))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 分类标签
            Menu {
                Button("💼 工作") {
                    onCategoryChange(.work)
                }
                Button("🎮 娱乐") {
                    onCategoryChange(.entertainment)
                }
            } label: {
                Text(record.category == .work ? "工作" : "娱乐")
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(record.category == .work ? Color(hex: "dcfce7") : Color(hex: "fef3c7"))
                    .foregroundColor(record.category == .work ? Color(hex: "166534") : Color(hex: "b45309"))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func getAppIcon(bundleId: String) -> NSImage? {
        guard let path = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)?.path else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: path)
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        if seconds < 60 { return "\(Int(seconds))秒" }
        if seconds < 3600 { return "\(Int(seconds / 60))分钟" }
        let hours = Int(seconds / 3600)
        let mins = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)小时\(mins)分"
    }
}

// MARK: - 设置视图
struct SettingsView: View {
    @EnvironmentObject var monitor: StressMonitor
    
    var body: some View {
        VStack(spacing: 20) {
            Text("压力监控设置")
                .font(.title2)
            
            Button("重置今日统计") {
                monitor.resetDailyStats()
            }
            
            Divider()
            
            Text("应用分类管理")
                .font(.headline)
            
            Text("点击弹窗中应用右侧的标签可以修改分类")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(30)
        .frame(width: 350, height: 200)
    }
}

// MARK: - 颜色扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 光标扩展
extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        self.onHover { inside in
            if inside {
                cursor.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(StressMonitor())
}
