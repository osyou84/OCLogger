//
//  OCLoggerable.swift
//
//
//  Created by Naoya on 2022/03/26.
//

protocol OCLoggerable {
    static func verbose(_ messages: Any..., file: String, function: String, line: Int)
    static func debug(_ messages: Any..., file: String, function: String, line: Int)
    static func info(_ messages: Any..., file: String, function: String, line: Int)
    static func warn(_ messages: Any..., file: String, function: String, line: Int)
    static func error(_ messages: Any..., file: String, function: String, line: Int)
}
