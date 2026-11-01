//
//  CodableAppStorage.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/6/3.
//

import Foundation

@propertyWrapper
public struct CodableAppStorage<T: Codable> {
    private let key: String
    private let store: UserDefaults
    private let defaultValue: T

    // 进程内引用缓存：保证同一个 key 在进程内始终返回同一个对象引用。
    // 对于 class 类型（如 MinecraftDirectory），扫描出的实例列表会挂在同一对象上，
    // 避免每次读取都重新 JSON 解码出一个全新的空对象，导致界面一直显示“加载中”。
    private static var cache: [String: Any] = [:]
    private static let cacheLock = NSLock()

    public var wrappedValue: T {
        get {
            Self.cacheLock.lock()
            defer { Self.cacheLock.unlock() }

            if let cached = Self.cache[key] as? T {
                return cached
            }

            let decoded: T
            if let data = store.data(forKey: key),
               let value = try? JSONDecoder().decode(T.self, from: data) {
                decoded = value
            } else {
                decoded = defaultValue
            }

            Self.cache[key] = decoded
            return decoded
        }
        set {
            Self.cacheLock.lock()
            Self.cache[key] = newValue
            Self.cacheLock.unlock()

            if let data = try? JSONEncoder().encode(newValue) {
                store.set(data, forKey: key)
            }
            DispatchQueue.main.async {
                DataManager.shared.objectWillChange.send()
            }
        }
    }

    public init(wrappedValue: T, _ key: String, store: UserDefaults = .standard) {
        self.key = key
        self.store = store
        self.defaultValue = wrappedValue
        // 初始写入（仅当没有值时）
        if store.data(forKey: key) == nil,
           let data = try? JSONEncoder().encode(wrappedValue) {
            store.set(data, forKey: key)
        }
    }
}
