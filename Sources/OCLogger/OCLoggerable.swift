//
//  OCLoggerable.swift
//
//
//  Created by Naoya on 2022/03/26.
//

/// `OCLogger` が準拠するロギングインターフェース。
///
/// このプロトコルに準拠することで、独自のロガー実装に差し替えることができる。
/// 各メソッドはデフォルト引数（`#file` / `#function` / `#line`）を持つため、
/// 呼び出し元の情報を自動的に取得する。
protocol OCLoggerable {
    /// `verbose` レベルのログを出力する。
    static func verbose(_ messages: Any..., file: String, function: String, line: Int)
    /// `debug` レベルのログを出力する。
    static func debug(_ messages: Any..., file: String, function: String, line: Int)
    /// `info` レベルのログを出力する。
    static func info(_ messages: Any..., file: String, function: String, line: Int)
    /// `warn` レベルのログを出力する。
    static func warn(_ messages: Any..., file: String, function: String, line: Int)
    /// `error` レベルのログを出力する。
    static func error(_ messages: Any..., file: String, function: String, line: Int)
}
