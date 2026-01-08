## 这是什么

将 Napcat.Shell 构建为一个 Appimage. 适用于 Linux x86_64 系统，如果需要其他 CPU 架构需要自己构建。

运行之后，数据文件保存在 $HOME/.config/napcat-qq/.config

## 如何运行

### 小提示

如果你在没有显示器的设备中运行，可以使用 [cage](https://github.com/cage-kiosk/cage) 用于支持无头模式。

可以使用以下命令：

```bash
# 1. 准备运行时目录
mkdir -p /tmp/runtime && chmod 700 /tmp/runtime

export WLR_BACKENDS=headless
export WLR_LIBINPUT_NO_DEVICES=1
export XDG_RUNTIME_DIR=/tmp/runtime
export NIXOS_OZONE_WL=1
export ELECTRON_OZONE_PLATFORM_HINT=wayland

# 2. 启动 cage，直接运行 napcat 的 Wayland 模式
# --ozone-platform=wayland: 强制开启 Wayland 支持
# --enable-features=WaylandWindowDecorations: 避免渲染崩溃
exec cage -d -s -- napcat \
  --ozone-platform=wayland \
  --enable-features=WaylandWindowDecorations
```

在上述命令中，`napcat` 可以是 `napcat.AppImage`

### Nix

Nix 是 NixOS Linux 发行版的包管理器，可以轻松安装和运行。如果你已经在使用 nix，可以直接运行：

```bash
nix run github:HumXC/napcat-nix#napcat
```

### Docker

```bash
docker run -it --rm -p 6099:6099 -v <数据目录>:/.config/napcat-qq/.config humxc/napcat:latest
```

#### Docker Compose

```yaml
services:
  napcat:
    image: humxc/napcat:latest
    volumes:
      - ./data:/.config/napcat-qq/.config
    ports:
      - 6099:6099
    hostname: Napcat
    # mac_address: xxxxxxxxxxxxx # 若需要固定 MAC 地址，请指定
```

### AppImage

AppImage 是一种轻量级的打包格式，可以直接运行。这是在非 NixOS 系统上运行该项目的推荐方式。

1. 从 Release 下载 .AppImage 文件，下载缓慢可以使用代理加速: <https://ghp.ci>

    下载之后的文件名与此处演示的命令中的文件名不同，注意辨别。

2. 赋予可执行权限

    ```bash
    chmod +x ./napcat_xxx.AppImage
    ```

3. 执行

    ```bash
    ./napcat_xxx.AppImage
    ```

## 构建

首先，确保你已经安装了 Nix

### Nix

```bash
nix build github:HumXC/napcat-nix#napcat
```

### Docker

```bash
nix build github:HumXC/napcat-nix#dockerImage
```

### AppImage

```bash
nix bundle --bundler github:ralismark/nix-appimage github:HumXC/napcat-nix#napcat
```

构建过程可能会比较漫长，不建议自己构建，可以使用 Github action

## 借鉴

<https://github.com/initialencounter/napcat.nix>

与以上仓库不同，该仓库仅是将 NapCap 和 QQ 打包在一起，并未提供沙盒环境
