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
