// StressMonitorApp.swift
// 压力监控 Mac App - 主入口

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
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    let stressMonitor = StressMonitor()
    var eventMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建状态栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            updateStatusBarIcon()
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // 创建弹出窗口
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 480)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MainView().environmentObject(stressMonitor)
        )
        
        // 监听点击外部关闭
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(nil)
            }
        }
        
        // 启动监控
        stressMonitor.startMonitoring()
        
        // 监听状态变化更新图标
        stressMonitor.$currentLevel.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateStatusBarIcon()
            }
        }.store(in: &stressMonitor.cancellables)
        
        // 隐藏 Dock 图标
        NSApp.setActivationPolicy(.accessory)
    }
    
    func updateStatusBarIcon() {
        if let button = statusItem.button {
            let emoji = stressMonitor.currentLevel.emoji
            button.title = emoji
        }
    }
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        stressMonitor.stopMonitoring()
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
