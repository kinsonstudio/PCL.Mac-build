//
//  PCL_MacApp.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/5/17.
//

import SwiftUI
import AppKit
import ObjectiveC

/// 允许 borderless 自定义窗口成为 key / main 窗口，否则 TextField 无法接收键盘输入
final class KeyableWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

@main
struct PCL_MacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        _ = AppStartTracker.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(WindowAccessor())
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("关于 PCL.Mac") {
                    DataManager.shared.router.setRoot(.others)
                    DataManager.shared.router.append(.about)
                }
            }
            
            CommandGroup(replacing: .appSettings) {
                Button("设置") {
                    DataManager.shared.router.setRoot(.settings)
                    DataManager.shared.router.append(.personalization)
                }
            }
            
            CommandGroup(replacing: .newItem) { } // 修复 #21
        }
        .windowStyle(.hiddenTitleBar) // 避免刚启动时闪一下标题栏
    }
}

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async {
            if let window = nsView.window {
                // 替换为可成为 key 窗口的子类，保证输入框能接收键盘
                object_setClass(window, KeyableWindow.self)
                if AppSettings.shared.showPclMacPopup {
                    window.setContentSize(NSSize(width: 815, height: 465))
                }
                window.isOpaque = false
                window.backgroundColor = NSColor.clear
                window.styleMask = [.borderless, .miniaturizable, .resizable]
                
                if let contentView = window.contentView {
                    contentView.wantsLayer = true
                    contentView.layer?.cornerRadius = 10
                    contentView.layer?.masksToBounds = true
                }
            }
        }
        return nsView
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
