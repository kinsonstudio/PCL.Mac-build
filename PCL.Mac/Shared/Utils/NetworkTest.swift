//
//  NetworkTest.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/6/3.
//

import Foundation
import Network

public class NetworkTest {
    public static let shared = NetworkTest()
    private let monitor = NWPathMonitor()
    private let lock = NSLock()
    private var isConnected: Bool = false

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            self.lock.lock()
            self.isConnected = (path.status == .satisfied)
            self.lock.unlock()
        }
        monitor.start(queue: DispatchQueue.global(qos: .userInitiated))
        lock.lock()
        isConnected = (monitor.currentPath.status == .satisfied)
        lock.unlock()
    }

    public func hasNetworkConnection(timeout: TimeInterval = 2.0) -> Bool {
        lock.lock()
        let connected = isConnected
        lock.unlock()
        return connected
    }
}
