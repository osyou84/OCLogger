//
//  OCLogger.swift
//
//
//  Created by Naoya on 2022/03/26.
//

import Foundation
import os

public enum LogLevel: String, Comparable, Sendable {
    case verbose = "VERBOSE"
    case debug = "DEBUG"
    case info = "INFO"
    case warn = "WARN"
    case error = "ERROR"

    private var order: Int {
        switch self {
        case .verbose: return 0
        case .debug:   return 1
        case .info:    return 2
        case .warn:    return 3
        case .error:   return 4
        }
    }

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.order < rhs.order
    }
}

public typealias OCLogHandler = @Sendable (LogLevel, String) -> Void

public struct OCLogger: OCLoggerable {

    /// 出力する最小ログレベル（これ未満のレベルは無視される）
    nonisolated(unsafe) public static var minimumLevel: LogLevel = .verbose

    /// タイムスタンプをログに含めるか
    nonisolated(unsafe) public static var showTimestamp: Bool = true

    nonisolated(unsafe) private static var handlers: [OCLogHandler] = []
    nonisolated(unsafe) private static var osLogAction: OCLogHandler?

    /// カスタムハンドラーを追加する（Crashlytics 等への転送に使用）
    public static func addHandler(_ handler: @escaping OCLogHandler) {
        handlers.append(handler)
    }

    /// 登録済みのカスタムハンドラーをすべて削除する
    public static func removeAllHandlers() {
        handlers.removeAll()
    }

    /// Apple の os.Logger にブリッジする
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public static func useOSLog(subsystem: String, category: String) {
        let logger = Logger(subsystem: subsystem, category: category)
        osLogAction = { level, message in
            switch level {
            case .verbose, .debug: logger.debug("\(message, privacy: .public)")
            case .info:            logger.info("\(message, privacy: .public)")
            case .warn:            logger.warning("\(message, privacy: .public)")
            case .error:           logger.error("\(message, privacy: .public)")
            }
        }
    }

    public static func verbose(_ messages: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .verbose, messages: messages, file: file, function: function, line: line)
    }

    public static func debug(_ messages: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .debug, messages: messages, file: file, function: function, line: line)
    }

    public static func info(_ messages: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .info, messages: messages, file: file, function: function, line: line)
    }

    public static func warn(_ messages: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .warn, messages: messages, file: file, function: function, line: line)
    }

    public static func error(_ errors: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .error, messages: errors, file: file, function: function, line: line)
    }
}

extension OCLogger {
    private static func getClassName(from filePath: String) -> String {
        guard let fileName = filePath.components(separatedBy: "/").last else { return "" }
        return String(fileName.split(separator: ".").first ?? "")
    }

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }

    private static func format(level: LogLevel, message: Any, file: String, function: String, line: Int) -> String {
        let location = "\(getClassName(from: file)).\(function) #\(line)"
        if showTimestamp {
            return "[\(level.rawValue)] \(timestamp()) \(location): \(message)"
        } else {
            return "[\(level.rawValue)] \(location): \(message)"
        }
    }

    private static func printLog(level: LogLevel, messages: [Any], file: String, function: String, line: Int) {
        guard !messages.isEmpty, level >= minimumLevel else { return }

        #if !RELEASE
        for message in messages {
            let formatted = format(level: level, message: message, file: file, function: function, line: line)
            print(formatted)
            osLogAction?(level, formatted)
            for handler in handlers {
                handler(level, formatted)
            }
        }
        #endif
    }
}
