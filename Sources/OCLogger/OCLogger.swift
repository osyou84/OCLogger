//
//  OCLogger.swift
//
//
//  Created by Naoya on 2022/03/26.
//

private enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warn = "WARN"
    case error = "ERROR"
}

public struct OCLogger: OCLoggerable {
    public static func debug(_ messages: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .debug, messages: messages, file: file, function: function, line: line)
    }
    
    public static func info(_ messages: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .debug, messages: messages, file: file, function: function, line: line)
    }

    public static func warn(_ messages: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .debug, messages: messages, file: file, function: function, line: line)
    }

    public static func error(_ errors: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .debug, messages: errors, file: file, function: function, line: line)
    }
}

extension OCLogger {
    private static func getClassName(from filePath: String) -> String {
        guard let fileName = filePath.components(separatedBy: "/").last else { return "" }

        return fileName.components(separatedBy: ".").first ?? ""
    }

    private static func printLog(level: LogLevel, messages: Any..., file: String, function: String, line: Int) {
        guard !messages.isEmpty else { return }
        
        #if !(RELEASE)
        for message in messages {
            print("[\(level.rawValue)] \(getClassName(from: file)).\(function) #\(line): \(message)")
        }
        #endif
    }
}
