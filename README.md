<p align="center"><img src="docs/app-overview.png" alt="Plain Text Keeper 功能预览"></p>

<h1 align="center">Plain Text Keeper</h1>
<p align="center">一个快捷键，把剪贴板恢复成干净纯文本。</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-Menu%20Bar-111111" alt="macOS menu bar">
  <img src="https://img.shields.io/badge/Dependencies-None-58A55C" alt="No dependencies">
  <img src="https://img.shields.io/badge/License-MIT-9A69DA" alt="MIT License">
</p>

## 功能一览

### 一键还原纯文本

点击菜单或使用快捷键，去掉刚复制内容里的字体、颜色和多余样式。

<p align="center"><img src="docs/feature-clean.png" alt="Plain Text Keeper 的清理剪贴板操作" width="900"></p>

### 偏好设置随时可调

快捷键和使用偏好集中管理，保持简单又不失灵活。

<p align="center"><img src="docs/feature-settings.png" alt="Plain Text Keeper 的设置入口" width="900"></p>

### 登录后自动就绪

可选择开机启动，让纯文本快捷键无需额外准备。

<p align="center"><img src="docs/feature-login.png" alt="Plain Text Keeper 的开机启动选项" width="900"></p>

## 为什么好用

- 默认按下 `Control + Option + Command + V` 清除当前剪贴板格式。
- 只处理你刚复制的文本：不轮询、不监控，也不会自动粘贴。
- 没有文本时保持剪贴板不变，并播放系统提示音。
- 菜单栏常驻、无 Dock 图标，可自定义快捷键和开机启动。

## 安装与使用

从 [GitHub Releases](https://github.com/ORDOABCHAOWT/plain-text-keeper/releases) 下载 App 并放入“应用程序”。复制富文本，按快捷键，再像平常一样粘贴即可。

## 开发与验证

```bash
Tests/verify_settings_ui.sh
Tests/verify_launch_feedback.sh
INSTALL_APP=0 ./build.sh
```

`INSTALL_APP=0` 只生成 `dist/Plain Text Keeper.app`，不会替换已安装客户端。

## License

[MIT](LICENSE) © ORDOABCHAOWT
