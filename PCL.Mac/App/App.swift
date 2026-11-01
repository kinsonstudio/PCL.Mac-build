//
//  PCL_MacApp.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/5/17.
//

import SwiftUI
import AppKit

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
            guard let window = nsView.window else { return }
            if AppSettings.shared.showPclMacPopup {
                window.setContentSize(NSSize(width: 815, height: 465))
            }
            window.isOpaque = false
            window.backgroundColor = NSColor.clear
            // 必须保留 .titled，窗口才能成为 key 窗口、TextField 才能接收键盘；
            // 标题栏由 .windowStyle(.hiddenTitleBar) + 透明标题栏隐藏，外观与原无边框一致
            window.styleMask = [.titled, .miniaturizable, .resizable, .fullSizeContentView]
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            // 隐藏系统标准按钮，使用界面内自定义的关闭 / 最小化按钮
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true

            if let contentView = window.contentView {
                contentView.wantsLayer = true
                contentView.layer?.cornerRadius = 10
                contentView.layer?.masksToBounds = true
            }
        }
        return nsView
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
