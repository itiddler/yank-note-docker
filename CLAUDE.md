# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个基于 `baseimage-kasmvnc` 的 Docker 镜像项目，用于在 KasmVNC 环境中运行 [Yank Note](https://github.com/purocean/yn)（一个基于 Electron + Monaco 的 Markdown 编辑器）。

## 核心架构

- **基础镜像**: `ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble`
  - 提供 KasmVNC + Openbox + Xvnc 桌面环境
  - 默认用户 `abc`（密码 `abc`），用户 `kasm-user`（密码 `kasm`）
  - DISPLAY 环境变量为 `:1`
  - s6-overlay 管理服务启动
- **Yank Note**: Electron 应用，通过 AppImage 方式安装到 `/opt/yank-note`
- **启动流程**: Openbox-session -> autostart -> yank-note-launcher.sh -> AppRun

## 文件结构

```
yank-note-docker/
├── Dockerfile                      # Docker 镜像构建文件
├── README.md                       # 使用说明
├── CLAUDE.md                       # 本文件
├── root/
│   └── defaults/
│       ├── autostart               # Openbox 启动时运行的应用
│       └── menu.xml                # 右键菜单配置
└── .github/
    └── workflows/
        └── build.yml               # GitHub Actions 构建/推送工作流
```

## GitHub Actions

- **触发条件**: push 到 main/master 分支，或手动 workflow_dispatch
- **主要步骤**: QEMU -> buildx -> 登录 ghcr.io -> 构建并推送镜像
- **镜像地址**: `ghcr.io/<owner>/yank-note-docker:<tag>`

## 构建参数 (Docker build-args)

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `YANK_NOTE_VERSION` | Yank Note 版本号 | `3.87.1` |
| `BUILD_DATE` | 构建日期标签 | GitHub run_id |

## KasmVNC 运行 Electron 应用的坑

1. **必须加 `--no-sandbox`**: 容器内无法使用 Linux namespace sandbox
2. **需要 `--disable-gpu`**: KasmVNC 环境无真实 GPU
3. **需要 `--disable-software-rasterizer`**: 避免软件光栅化问题
4. **需要 `--disable-dev-shm-usage`**: /dev/shm 在容器中有限制
5. **避免 `--kiosk`**: Kiosk 模式会强制全屏，干扰桌面环境

## 常用命令

```bash
# 本地构建
docker build -t yank-note-docker .

# 本地运行
docker run -p 3000:3000 -p 3001:3001 yank-note-docker

# 推送到 GitHub Container Registry（需要登录）
echo $GITHUB_TOKEN | docker login ghcr.io -u <username> --password-stdin
docker tag yank-note-docker ghcr.io/<owner>/yank-note-docker:latest
docker push ghcr.io/<owner>/yank-note-docker:latest
```
