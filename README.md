# OCLogger

[![GitHub release](https://img.shields.io/github/release/osyou84/OCLogger)](https://github.com/osyou84/OCLogger/releases/latest)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue)](https://github.com/osyou84/OCLogger/blob/master/LICENSE)

Swift 製の軽量ロギングライブラリです。ログレベルフィルタリング・タイムスタンプ出力・カスタムハンドラー・`os.Logger` 連携をシンプルな API で提供します。

## 動作環境

| 項目 | バージョン |
|------|-----------|
| Swift | 6.0+ |
| iOS | 16.0+ |
| macOS | 13.0+ |
| Xcode | 16.0+ |

## 機能

- **5段階のログレベル** — `verbose` / `debug` / `info` / `warn` / `error`
- **ログレベルフィルタリング** — `minimumLevel` で出力レベルを動的に制御
- **タイムスタンプ** — ミリ秒精度のタイムスタンプを付与（オン/オフ切替可能）
- **カスタムハンドラー** — Crashlytics 等の外部サービスへ自由に転送
- **os.Logger 連携** — Apple の統合ログシステムと橋渡し（iOS 14+ / macOS 11+）

> **Note**
> `#if !RELEASE` フラグが立っていない場合のみ出力されます。本番ビルドでは自動的に無効になります。

## インストール

### Swift Package Manager

`Package.swift` の `dependencies` に追加してください。

```swift
dependencies: [
    .package(url: "https://github.com/osyou84/OCLogger.git", from: "<version>")
]
```

ターゲットに依存関係を追加します。

```swift
targets: [
    .target(
        name: "MyTarget",
        dependencies: ["OCLogger"]
    )
]
```

Xcode から追加する場合は **File > Add Package Dependencies…** からリポジトリ URL を入力してください。

## 使い方

### 基本的なログ出力

```swift
import OCLogger

OCLogger.verbose("詳細なデバッグ情報")
OCLogger.debug("デバッグ情報")
OCLogger.info("一般的な情報")
OCLogger.warn("警告")
OCLogger.error("エラー発生")

// 出力例:
// [DEBUG] 2026-03-01 12:00:00.123 ViewController.viewDidLoad() #42: デバッグ情報
// [ERROR] 2026-03-01 12:00:00.124 ViewController.viewDidLoad() #43: エラー発生
```

複数の値を一度に渡すことも可能です。

```swift
let user = "alice"
let code = 404
OCLogger.warn("ユーザー:", user, "ステータス:", code)
// [WARN] 2026-03-01 12:00:00.125 ViewController.viewDidLoad() #10: ユーザー:
// [WARN] 2026-03-01 12:00:00.125 ViewController.viewDidLoad() #10: alice
// （各引数が 1 行ずつ出力されます）
```

### ログレベルフィルタリング

`minimumLevel` プロパティで出力するログの下限レベルを設定できます。

```swift
// warn 以上のみ出力（debug / info は無視される）
OCLogger.minimumLevel = .warn

OCLogger.debug("出力されない")   // 無視
OCLogger.info("出力されない")    // 無視
OCLogger.warn("出力される")      // 出力
OCLogger.error("出力される")     // 出力
```

デフォルトは `.verbose`（全レベル出力）です。

### タイムスタンプ

```swift
// タイムスタンプを非表示にする
OCLogger.showTimestamp = false

OCLogger.info("シンプルなログ")
// [INFO] ViewController.viewDidLoad() #10: シンプルなログ
```

デフォルトは `true`（タイムスタンプあり）です。

### カスタムハンドラー

`addHandler` でログ出力をフックできます。Crashlytics や Sentry など外部サービスへの転送に利用してください。

```swift
// アプリ起動時に登録
OCLogger.addHandler { level, message in
    if level >= .warn {
        Crashlytics.log(message)
    }
}

// 登録したハンドラーをすべて削除
OCLogger.removeAllHandlers()
```

### os.Logger 連携

Apple の `os.Logger` に橋渡しすることで、Console.app や Instruments での絞り込みが可能になります。

```swift
if #available(iOS 14.0, macOS 11.0, *) {
    OCLogger.useOSLog(subsystem: "com.example.app", category: "network")
}

// 以降のログは os.Logger 経由でも出力される
OCLogger.info("ネットワークリクエスト開始")
```

## ライセンス

[MIT License](./LICENSE)
Copyright © 2022 Osyou create
