//
//  Secrets.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/7/13.
//

import Foundation

public let ARTIFACT_PAT: String = ""
public let CLIENT_ID: String = ""
public let THEME_KEY: String = ""

public class Secrets {
    public static func getClientID() -> String {
        if !CLIENT_ID.starts(with: "{{") {
            return CLIENT_ID
        }
        
        return ProcessInfo.processInfo.environment["CLIENT_ID"] ?? "" // 本地调试使用
    }
}
