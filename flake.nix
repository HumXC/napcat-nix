{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      napcat = pkgs.callPackage ./napcat.nix {};
    in {
      packages = {
        default = napcat;
        napcat = napcat;
        dockerImage = pkgs.dockerTools.buildImage {
          name = "napcat";
          tag = "latest";

          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = with pkgs; [
              napcat
              bashInteractive
              coreutils
              cacert
              curl
              cage
            ];
            pathsToLink = ["/bin" "/etc" "/var"];
          };
          config = {
            Cmd = [
              "/bin/bash"
              "-c"
              ''
                # 1. 准备运行时目录
                mkdir -p /tmp/runtime && chmod 700 /tmp/runtime
                export XDG_RUNTIME_DIR=/tmp/runtime

                # 2. 启动 cage，直接运行 napcat 的 Wayland 模式
                # --ozone-platform=wayland: 强制开启 Wayland 支持
                # --enable-features=WaylandWindowDecorations: 避免渲染崩溃
                exec /bin/cage -d -s -- /bin/napcat \
                  --ozone-platform=wayland \
                  --enable-features=WaylandWindowDecorations
              ''
            ];

            Env = [
              "PATH=/bin"
              "WLR_BACKENDS=headless"
              "WLR_LIBINPUT_NO_DEVICES=1"
              "XDG_RUNTIME_DIR=/tmp/runtime"
              # 强制 Electron 使用 Wayland
              "NIXOS_OZONE_WL=1"
              "ELECTRON_OZONE_PLATFORM_HINT=wayland"
            ];
          };
        };
      };
    });
}
