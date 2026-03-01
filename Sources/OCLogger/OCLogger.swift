//
//  OCLogger.swift
//
//
//  Created by Naoya on 2022/03/26.
//

import Foundation
import os

/// ログの重要度を表す列挙型。
///
/// `verbose` が最も低く、`error` が最も高い。
/// `Comparable` に準拠しているため、`minimumLevel` によるフィルタリングに使用できる。
///
/// ```swift
/// LogLevel.debug < LogLevel.warn  // true
/// ```
public enum LogLevel: String, Comparable, Sendable {
    /// 最も詳細なトレース情報。通常の開発時のみ使用する。
    case verbose = "VERBOSE"
    /// デバッグ目的の情報。リリース前に確認・整理することを推奨する。
    case debug   = "DEBUG"
    /// 一般的な動作状況の記録。
    case info    = "INFO"
    /// 問題ではないが注意が必要な状況。
    case warn    = "WARN"
    /// 処理の継続に支障をきたすエラー。
    case error   = "ERROR"

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

/// ログハンドラーの型エイリアス。
///
/// `addHandler(_:)` に渡すクロージャの型。
/// - Parameters:
///   - level: 発生したログのレベル。
///   - message: フォーマット済みのログ文字列。
public typealias OCLogHandler = @Sendable (LogLevel, String) -> Void

/// ログ出力を行う構造体。
///
/// すべてのメソッドは `static` で提供されるため、インスタンス化は不要。
///
/// ```swift
/// OCLogger.minimumLevel = .warn
/// OCLogger.info("この行は出力されない")
/// OCLogger.warn("この行は出力される")
/// ```
///
/// - Note: `#if !RELEASE` が定義されていない場合のみ出力されます。
public struct OCLogger: OCLoggerable {

    /// 出力する最小ログレベル。これ未満のレベルは無視される。
    ///
    /// デフォルト値は `.verbose`（全レベル出力）。
    /// アプリ起動時に設定することを推奨する。
    nonisolated(unsafe) public static var minimumLevel: LogLevel = .verbose

    /// タイムスタンプをログに含めるかどうか。
    ///
    /// `true` の場合、`yyyy-MM-dd HH:mm:ss.SSS` 形式で出力する。
    /// デフォルト値は `true`。
    nonisolated(unsafe) public static var showTimestamp: Bool = true

    /// 登録済みのカスタムハンドラー一覧。
    nonisolated(unsafe) private static var handlers: [OCLogHandler] = []

    /// os.Logger へのブリッジアクション。`useOSLog(subsystem:category:)` で設定される。
    nonisolated(unsafe) private static var osLogAction: OCLogHandler?

    // MARK: - ハンドラー管理

    /// カスタムハンドラーを追加する。
    ///
    /// ハンドラーはログが出力されるたびに呼び出される。
    /// Crashlytics・Sentry などの外部サービスへの転送に利用できる。
    ///
    /// ```swift
    /// OCLogger.addHandler { level, message in
    ///     if level >= .warn {
    ///         Crashlytics.log(message)
    ///     }
    /// }
    /// ```
    public static func addHandler(_ handler: @escaping OCLogHandler) {
        handlers.append(handler)
    }

    /// 登録済みのカスタムハンドラーをすべて削除する。
    ///
    /// テストや再初期化時に使用する。
    public static func removeAllHandlers() {
        handlers.removeAll()
    }

    // MARK: - os.Logger 連携

    /// Apple の `os.Logger` にログ出力を橋渡しする。
    ///
    /// 設定後のすべてのログが `os.Logger` 経由でも出力される。
    /// Console.app や Instruments でのフィルタリングが可能になる。
    ///
    /// ```swift
    /// if #available(iOS 14.0, macOS 11.0, *) {
    ///     OCLogger.useOSLog(subsystem: "com.example.app", category: "network")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - subsystem: アプリの識別子（通常はバンドル ID）。
    ///   - category: ログのカテゴリー名。
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

    // MARK: - ログ出力メソッド

    /// `verbose` レベルのログを出力する。
    /// - Parameters:
    ///   - messages: 出力する値（複数可）。
    ///   - file: 呼び出し元のファイルパス（自動設定）。
    ///   - function: 呼び出し元の関数名（自動設定）。
    ///   - line: 呼び出し元の行番号（自動設定）。
    public static func verbose(_ messages: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .verbose, messages: messages, file: file, function: function, line: line)
    }

    /// `debug` レベルのログを出力する。
    /// - Parameters:
    ///   - messages: 出力する値（複数可）。
    ///   - file: 呼び出し元のファイルパス（自動設定）。
    ///   - function: 呼び出し元の関数名（自動設定）。
    ///   - line: 呼び出し元の行番号（自動設定）。
    public static func debug(_ messages: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .debug, messages: messages, file: file, function: function, line: line)
    }

    /// `info` レベルのログを出力する。
    /// - Parameters:
    ///   - messages: 出力する値（複数可）。
    ///   - file: 呼び出し元のファイルパス（自動設定）。
    ///   - function: 呼び出し元の関数名（自動設定）。
    ///   - line: 呼び出し元の行番号（自動設定）。
    public static func info(_ messages: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .info, messages: messages, file: file, function: function, line: line)
    }

    /// `warn` レベルのログを出力する。
    /// - Parameters:
    ///   - messages: 出力する値（複数可）。
    ///   - file: 呼び出し元のファイルパス（自動設定）。
    ///   - function: 呼び出し元の関数名（自動設定）。
    ///   - line: 呼び出し元の行番号（自動設定）。
    public static func warn(_ messages: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .warn, messages: messages, file: file, function: function, line: line)
    }

    /// `error` レベルのログを出力する。
    /// - Parameters:
    ///   - errors: 出力する値（複数可）。
    ///   - file: 呼び出し元のファイルパス（自動設定）。
    ///   - function: 呼び出し元の関数名（自動設定）。
    ///   - line: 呼び出し元の行番号（自動設定）。
    public static func error(_ errors: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        printLog(level: .error, messages: errors, file: file, function: function, line: line)
    }
}

// MARK: - Internal

extension OCLogger {

    /// ファイルパスからクラス名（ファイル名の拡張子なし部分）を取得する。
    private static func getClassName(from filePath: String) -> String {
        guard let fileName = filePath.components(separatedBy: "/").last else { return "" }
        return String(fileName.split(separator: ".").first ?? "")
    }

    /// 現在時刻を `yyyy-MM-dd HH:mm:ss.SSS` 形式の文字列で返す。
    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }

    /// ログ文字列をフォーマットして返す。
    /// `showTimestamp` が `true` の場合はタイムスタンプを先頭に付与する。
    private static func format(level: LogLevel, message: Any, file: String, function: String, line: Int) -> String {
        let location = "\(getClassName(from: file)).\(function) #\(line)"
        if showTimestamp {
            return "[\(level.rawValue)] \(timestamp()) \(location): \(message)"
        } else {
            return "[\(level.rawValue)] \(location): \(message)"
        }
    }

    /// 実際のログ出力処理。
    ///
    /// `minimumLevel` によるフィルタリングを行い、
    /// 標準出力・`osLogAction`・登録済みハンドラーの順に出力する。
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
