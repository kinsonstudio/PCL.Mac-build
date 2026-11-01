//
//  LaunchPrecheck.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/7/20.
//

import Foundation
import AppKit

public enum JavaCheckError: Error {
    case javaNotFound
    case noUsableJava(minVersion: Int)
    case javaNotSupport
    case invalidMemoryConfiguration
    case rosetta
}

public enum AccountCheckError: Error {
    case missingAccount
    case noMicrosoftAccount
}

public class LaunchPrecheck {
    public static func checkJava(_ instance: MinecraftInstance, _ options: LaunchOptions) -> Result<Void, JavaCheckError> {
        log("[launchPrecheck] 正在进行 Java 检查")
        let manifest = instance.manifest
        let minVersion = MinecraftInstance.getMinJavaVersion(instance.version, manifest: manifest)
        let suitableJava = MinecraftInstance.findSuitableJava(instance.version, manifest: manifest)
        if DataManager.shared.javaVirtualMachines
            .filter({ $0.executableURL.path != "/usr/bin/java" })
            .count == 0 {
            err("[launchPrecheck] 用户未安装 Java")
            return .failure(.javaNotFound)
        }
        
        if instance.config.maxMemory == 0 {
            return .failure(.invalidMemoryConfiguration)
        }
        
        guard let suitableJava else {
            err("[launchPrecheck] 无可用 Java。最低版本: \(minVersion)")
            return .failure(.noUsableJava(minVersion: minVersion))
        }
        
        // 当前已选 Java 缺失、是系统 stub、或版本不满足需求时，刷新到合适的 JVM
        let currentPath = instance.config.javaURL?.path
        let currentJvm = DataManager.shared.javaVirtualMachines.first { $0.executableURL.path == currentPath }
        let currentVersion = currentJvm?.version ?? 0
        let needsRefresh = currentPath == nil
            || !FileManager.default.fileExists(atPath: currentPath!)
            || currentPath == "/usr/bin/java"
            || currentVersion < minVersion
        if needsRefresh {
            instance.config.javaURL = suitableJava.executableURL
            instance.saveConfig()
        }
        let javaArchitecture = Architecture.getArchOfFile(instance.config.javaURL!)
        
        if Architecture.system == .x64 && javaArchitecture == .arm64 {
            err("[launchPrecheck] Java 架构不兼容")
            return .failure(.javaNotSupport)
        } else if Architecture.system == .arm64 && javaArchitecture == .x64 {
            // 没有满足版本的原生 JDK 时，允许 Rosetta 转译运行，仅警告不阻断启动
            warn("[launchPrecheck] 正在使用 x64 Java（Rosetta 转译），性能可能受限")
        }
        
        return .success(())
    }
    
    public static func checkAccount(_ instance: MinecraftInstance, _ options: LaunchOptions) -> Result<Void, AccountCheckError> {
        guard let account = AccountManager.shared.getAccount() else {
            err("无法启动 Minecraft: 未设置账号")
            return .failure(.missingAccount)
        }
        
        options.account = account
        
        if !AppSettings.shared.hasMicrosoftAccount {
            debug("[launchPrecheck] 未登录过正版账号")
            return .failure(.noMicrosoftAccount)
        }
        
        return .success(())
    }
}
