// MainView.swift
// 主界面 v2.0 - 悬浮窗口 + 状态日历

import SwiftUI
import AppKit

// MARK: - 悬浮窗口主视图
struct FloatingWindowView: View {
    @EnvironmentObject var stressMonitor: StressMonitor
    @State private var isExpanded = false          // 第1级 -> 第2级
    @State private var showAppList = false         // hover 展开应用列表
    @State private var showCalendar = false
    @State private var bounceAnimation = false
    
    // 根据展开状态计算窗口宽度
    private var windowWidth: CGFloat {
        if showAppList {
            return 340
        } else if isExpanded {
            return 300
        } else {
            return 200
        }
    }
    
    // 统一的动画配置
    private var smoothAnimation: Animation {
        .easeInOut(duration: 0.25)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 主卡片（始终显示）
            mainCard
            
            // 第2级：工作/娱乐比例（点击展开）
            if isExpanded {
                expandedContent
            }
            
            // 底部按钮（展开时显示）
            if isExpanded {
                bottomButtons
            }
        }
        .frame(width: windowWidth)
        .clipped()  // 防止内容溢出造成闪烁
        .background(
            ZStack {
                // 磨砂玻璃效果背景
                VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // 半透明叠加层增强效果
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            }
            .shadow(color: .black.opacity(0.25), radius: 15, x: 0, y: 8)
        )
        .animation(smoothAnimation, value: isExpanded)
        .animation(smoothAnimation, value: showAppList)
    }
    
    // MARK: - 主卡片（第1级）
    private var mainCard: some View {
        HStack(spacing: 12) {
            // 表情按钮
            Button(action: {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    bounceAnimation = true
                }
                let _ = stressMonitor.performStressRelief()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    bounceAnimation = false
                }
            }) {
                Text(stressMonitor.currentLevel.emoji)
                    .font(.system(size: 48))
                    .scaleEffect(bounceAnimation ? 1.2 : 1.0)
                    .frame(minWidth: 56)
            }
            .buttonStyle(.plain)
            
            // 状态信息
            VStack(alignment: .leading, spacing: 2) {
                Text(stressMonitor.currentLevel.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(stressMonitor.formatTime(stressMonitor.totalTime))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 展开/收起按钮
            Button(action: {
                isExpanded.toggle()
                if !isExpanded {
                    showAppList = false  // 收起时也隐藏应用列表
                }
            }) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 28, height: 28)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
    
    // MARK: - 展开的内容（第2级）
    private var expandedContent: some View {
        VStack(spacing: 12) {
            Divider()
                .padding(.horizontal)
            
            // 时间统计
            timeStatsView
            
            // 进度条
            progressBarView
            
            // 状态日历按钮
            calendarButton
            
            // 今日应用区域（hover 展开）
            appListSection
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - 今日应用区域（点击展开）
    private var appListSection: some View {
        VStack(spacing: 8) {
            // 应用列表标题（点击触发展开/收起）
            Button(action: {
                showAppList.toggle()
            }) {
                HStack {
                    Text("📱 今日应用")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(stressMonitor.appUsageRecords.count)个")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.7))
                    Image(systemName: showAppList ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(showAppList ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            
            // 应用列表（展开时显示）
            if showAppList {
                appListContent
            }
        }
    }
    
    // MARK: - 应用列表内容
    private var appListContent: some View {
        VStack(spacing: 6) {
            if stressMonitor.appUsageRecords.isEmpty {
                // 空状态
                VStack(spacing: 8) {
                    Text("📱")
                        .font(.system(size: 24))
                    Text("暂无应用记录")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("使用应用后会自动记录")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                // 直接显示应用列表（最多显示10个）
                let sortedRecords = stressMonitor.appUsageRecords.values
                    .sorted { $0.totalTime > $1.totalTime }
                
                ForEach(Array(sortedRecords.prefix(10).enumerated()), id: \.element.id) { index, record in
                    appRowItem(record: record, index: index + 1)
                }
                
                // 如果超过10个，显示提示
                if sortedRecords.count > 10 {
                    Text("还有 \(sortedRecords.count - 10) 个应用...")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - 时间统计
    private var timeStatsView: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("💼")
                    Text("工作")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Text(stressMonitor.formatTime(stressMonitor.workTime))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
            }
            
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("🎮")
                    Text("娱乐")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Text(stressMonitor.formatTime(stressMonitor.entertainmentTime))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - 进度条
    private var progressBarView: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    // 工作进度
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(stressMonitor.currentLevel.color))
                        .frame(width: geometry.size.width * CGFloat(stressMonitor.workRatio))
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("工作占比")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(stressMonitor.workRatio * 100))%")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - 状态日历按钮
    private var calendarButton: some View {
        Button(action: {
            showCalendar = true
        }) {
            HStack {
                Image(systemName: "calendar")
                Text("状态日历")
                    .font(.system(size: 12))
                Spacer()
                Text("\(stressMonitor.statusCalendar.count)天记录")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .sheet(isPresented: $showCalendar) {
            CalendarView()
                .environmentObject(stressMonitor)
        }
    }
    
    // MARK: - 应用行项目
    private func appRowItem(record: AppUsageRecord, index: Int) -> some View {
        let currentCategory = stressMonitor.customCategories[record.bundleId] ?? record.category
        
        return HStack(spacing: 8) {
            // 序号
            Text("\(index)")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary.opacity(0.6))
                .frame(width: 16)
            
            // 应用名称
            Text(record.appName)
                .font(.system(size: 12))
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer(minLength: 4)
            
            // 使用时间
            Text(stressMonitor.formatTime(record.totalTime))
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
            
            // 分类标签（可点击切换）
            Button(action: {
                let newCategory: AppCategory = currentCategory == .work ? .entertainment : .work
                stressMonitor.setCategory(for: record.bundleId, category: newCategory)
            }) {
                HStack(spacing: 3) {
                    Text(currentCategory == .work ? "💼" : "🎮")
                        .font(.system(size: 10))
                    Text(currentCategory.displayName)
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(currentCategory == .work ? Color.blue : Color.green)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.05))
        )
    }
    
    // MARK: - 底部按钮
    private var bottomButtons: some View {
        HStack(spacing: 12) {
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("退出")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }
}

// MARK: - 状态日历视图
struct CalendarView: View {
    @EnvironmentObject var stressMonitor: StressMonitor
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("状态日历")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            if stressMonitor.statusCalendar.isEmpty {
                // 空状态
                VStack(spacing: 12) {
                    Text("📅")
                        .font(.system(size: 48))
                    Text("暂无历史记录")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("每天结束时会自动记录状态")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 日历列表
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(stressMonitor.statusCalendar.reversed()) { record in
                            DayRecordCard(record: record)
                        }
                    }
                    .padding()
                }
            }
            
            // 今日状态预览
            VStack(spacing: 8) {
                Divider()
                HStack {
                    Text("今日")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(stressMonitor.currentLevel.emoji)
                    Text(stressMonitor.formatTime(stressMonitor.totalTime))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .frame(width: 320, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - 日期记录卡片
struct DayRecordCard: View {
    let record: DailyStatusRecord
    
    var body: some View {
        HStack(spacing: 12) {
            // 日期
            VStack(spacing: 2) {
                Text(record.formattedDate)
                    .font(.system(size: 14, weight: .semibold))
                Text(record.weekdayString)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .frame(width: 50)
            
            // 状态表情
            Text(record.finalLevel.emoji)
                .font(.system(size: 28))
            
            // 详情
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("💼 \(formatTime(record.workTime))")
                        .font(.system(size: 11))
                    Text("🎮 \(formatTime(record.entertainmentTime))")
                        .font(.system(size: 11))
                }
                
                // 进度条
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(record.finalLevel.color))
                            .frame(width: geometry.size.width * CGFloat(record.workRatio))
                    }
                }
                .frame(height: 4)
                
                // Top 应用
                if !record.topApps.isEmpty {
                    Text(record.topApps.joined(separator: " · "))
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h\(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - 设置视图（保留兼容性）
struct SettingsView: View {
    @EnvironmentObject var stressMonitor: StressMonitor
    
    var body: some View {
        VStack(spacing: 20) {
            Text("压力监控设置")
                .font(.title)
            
            Text("悬浮窗口会显示在屏幕上")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}

// MARK: - 主视图（Popover 内容，保留兼容）
struct MainView: View {
    @EnvironmentObject var stressMonitor: StressMonitor
    
    var body: some View {
        FloatingWindowView()
            .environmentObject(stressMonitor)
    }
}

// MARK: - 磨砂玻璃效果视图
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.isEmphasized = true
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
