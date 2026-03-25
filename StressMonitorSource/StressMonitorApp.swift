// StressMonitorApp.swift
// 压力监控 Mac App - 主入口 v2.0
// 支持屏幕悬浮窗口

import SwiftUI
import AppKit

@main
struct StressMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(appDelegate.stressMonitor)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var floatingWindow: NSWindow!
    var statusItem: NSStatusItem?
    let stressMonitor = StressMonitor()
    var eventMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建悬浮窗口
        setupFloatingWindow()
        
        // 创建状态栏图标（可选，点击可显示/隐藏悬浮窗口）
        setupStatusItem()
        
        // 启动监控
        stressMonitor.startMonitoring()
        
        // 监听状态变化更新窗口
        stressMonitor.$currentLevel.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateStatusBarIcon()
            }
        }.store(in: &stressMonitor.cancellables)
        
        // 隐藏 Dock 图标
        NSApp.setActivationPolicy(.accessory)
    }
    
    // MARK: - 设置悬浮窗口
    private func setupFloatingWindow() {
        // 创建悬浮窗口
        floatingWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 70),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // 窗口属性
        floatingWindow.isOpaque = false
        floatingWindow.backgroundColor = .clear
        floatingWindow.level = .floating // 悬浮在其他窗口上方
        floatingWindow.collectionBehavior = [.canJoinAllSpaces, .stationary] // 所有桌面可见
        floatingWindow.isMovableByWindowBackground = true // 可拖动
        floatingWindow.hasShadow = false // 视图自己处理阴影
        
        // 设置内容视图
        let hostingView = NSHostingView(
            rootView: FloatingWindowView()
                .environmentObject(stressMonitor)
        )
        floatingWindow.contentView = hostingView
        
        // 设置初始位置（屏幕右上角）
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowFrame = floatingWindow.frame
            let x = screenFrame.maxX - windowFrame.width - 20
            let y = screenFrame.maxY - windowFrame.height - 20
            floatingWindow.setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        // 显示窗口
        floatingWindow.orderFront(nil)
        
        // 监听窗口大小变化（展开/收起时）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResize),
            name: NSWindow.didResizeNotification,
            object: floatingWindow
        )
    }
    
    @objc private func windowDidResize(_ notification: Notification) {
        // 确保窗口不会超出屏幕边界
        if let screen = NSScreen.main {
            var frame = floatingWindow.frame
            let screenFrame = screen.visibleFrame
            
            // 调整位置确保在屏幕内
            if frame.maxX > screenFrame.maxX {
                frame.origin.x = screenFrame.maxX - frame.width
            }
            if frame.minX < screenFrame.minX {
                frame.origin.x = screenFrame.minX
            }
            if frame.maxY > screenFrame.maxY {
                frame.origin.y = screenFrame.maxY - frame.height
            }
            if frame.minY < screenFrame.minY {
                frame.origin.y = screenFrame.minY
            }
            
            floatingWindow.setFrameOrigin(frame.origin)
        }
    }
    
    // MARK: - 设置状态栏图标
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            updateStatusBarIcon()
            button.action = #selector(toggleFloatingWindow)
            button.target = self
        }
    }
    
    func updateStatusBarIcon() {
        if let button = statusItem?.button {
            let emoji = stressMonitor.currentLevel.emoji
            button.title = emoji
        }
    }
    
    @objc func toggleFloatingWindow() {
        if floatingWindow.isVisible {
            floatingWindow.orderOut(nil)
        } else {
            floatingWindow.orderFront(nil)
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        stressMonitor.stopMonitoring()
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
