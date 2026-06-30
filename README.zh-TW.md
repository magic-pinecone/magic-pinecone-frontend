# magic-pinecone-frontend

<p align="center">
  <a href="README.md">English</a> | 正體中文
</p>

<p align="center">
  <img src="docs/assets/app_icon.png" width="256" />
  <p align="center">神奇松果，為中大學生打造的一站式校園平台。</p>
</p>

<p align="center">
    <img alt="Made with Flutter" src="https://img.shields.io/badge/made_with-Flutter-blue">
    <img alt="MIT" src="https://img.shields.io/github/license/magic-pinecone/magic-pinecone-frontend" />
</p>

> 專案還處於早期階段，有興趣的話歡迎試試看 [Lite 版本](https://magic-pinecone.github.io/magic-pinecone-lite/) 吧！

神奇松果（Magic Pinecone）是一個基於 Flutter 的前端應用程式，旨在為中大學生提供便利的校園服務。；

## 功能

- **Portal 整合**：內建 WebView 元件，可直接在 App 中使用校園 Portal 服務。
- **主題支援**：包含亮色與深色模式設定。
- **Session 管理**：提供半自動 Portal session 管理，協助簡化 Portal 使用流程，且不儲存 Basic Auth 帳號密碼。

## 開始使用

### 前置需求

- Flutter SDK，建議使用最新 stable 版本
- Dart SDK
- 目標平台所需的相關 SDK，例如 iOS 需要 Xcode、Android 需要 Android Studio

### 安裝

1. 複製 repository：
   ```bash
   git clone https://github.com/magic-pinecone/magic-pinecone-frontend.git
   ```
2. 安裝相依套件：
   ```bash
   flutter pub get
   ```
3. 執行應用程式：
   ```bash
   flutter run
   ```

---

## 致謝

**應用程式圖示**：由**吳芮葶**設計。

**Course Finder Fetcher**：[NCU-Course-Finder-DataFetcher-v2](https://github.com/zetaraku/NCU-Course-Finder-DataFetcher-v2)。

## 授權

本專案採用 MIT License，詳情請參考 [LICENSE](LICENSE)。
