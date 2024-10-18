## 这是什么

将 Napcat.Shell 构建为一个 Appimage. 适用于 Linux x86_64 系统，如果需要其他 CPU 架构需要自己构建。

运行之后，数据文件保存在 $HOME/.config/napcat

TODO: 将 xvfb 也打包进去
## 如何运行

1. 从 Release 下载 .AppImage 文件，下载缓慢可以使用代理加速: https://ghp.ci

    下载之后的文件名与此处演示的命令中的文件名不同，注意辨别。

2. 赋予可执行权限

    ```bash
    chmod +x ./napcat_xxx.AppImage
    ```

3. 执行

    ```bash
    ./napcat_xxx.AppImage
    ```

    如果出现以下错误:

    ```bash
    [167581:1005/072949.985400:ERROR:ozone_platform_x11.cc(245)] Missing X server or $DISPLAY
    [167581:1005/072949.985538:ERROR:env.cc(258)] The platform failed to  initialize.  Exiting.
    ```

    可以使用 xvfb-run 运行，在你的发行版上安装 xvfb-run，然后:

    ```bash
    xvfb -a ./napcat_xxx.AppImage
    ```

## 如何构建

1. 安装 nix

2. 克隆此仓库

3. 进入此仓库目录执行：

    ```bash
    nix bundle --bundler github:ralismark/nix-appimage .#napcat
    ```

    构建过程可能会比较漫长，不建议自己构建，可以使用 Github action

## 借鉴

https://github.com/initialencounter/napcat.nix

与以上仓库不同，该仓库仅是将 NapCap 和 QQ 打包在一起，并未提供沙盒环境
