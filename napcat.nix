{
  pkgs,
  lib,
  ...
}: let
  sources = import ./sources.nix {inherit (pkgs) fetchurl;};
  napcat-shell-zip = sources.napcat.src;

  currentSystem = pkgs.stdenv.hostPlatform.system;
  src = sources.qq.${currentSystem}.src or (throw "Unsupported system: ${currentSystem}");
  version = sources.qq.${currentSystem}.version or (throw "Unsupported system: ${currentSystem}");

  patched = pkgs.qq.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [pkgs.unzip]; # 添加 unzip 到依赖中
    inherit version src;
    postFixup = ''
      mkdir -p $out/opt/QQ/resources/app/app_launcher/napcat
      napcat_dir=$out/opt/QQ/resources/app/app_launcher/napcat
      unzip ${napcat-shell-zip} -d $napcat_dir

      # 移动 qqnt.json 到正确的位置并重命名为 package.json
      # 注意：原始的 package.json 位于 resources/app/package.json
      rm -rf $out/opt/QQ/resources/app/package.json
      mv $napcat_dir/qqnt.json $out/opt/QQ/resources/app/package.json

      # 修改 loadNapCat.js
      # 官方脚本中：
      # echo "(async () => {await import('file:///' + TARGET_FOLDER + '/napcat/napcat.mjs');})();" > QQ_BASE_PATH + "/resources/app/loadNapCat.js"
      # TARGET_FOLDER 是 resources/app/app_launcher

      echo "(async () => {await import('file:///' + require('path').join(require('os').homedir(), '.config/napcat/napcat.mjs'));})();" > $out/opt/QQ/resources/app/loadNapCat.js
    '';
    meta = {};
  });
in
  pkgs.writeShellApplication {
    name = "napcat";
    runtimeInputs = [patched pkgs.coreutils];
    text = ''
      export HOME="$HOME/.config/napcat-qq"
      if [ ! -d "$HOME/.config/napcat" ]; then
        mkdir -p "$HOME/.config"
        # 复制初始配置
        cp -r ${patched}/opt/QQ/resources/app/app_launcher/napcat "$HOME/.config"
        chmod -R u+w "$HOME/.config/napcat"
        echo "Directory $HOME/.config/napcat created."
      fi
      exec qq --no-sandbox "$@"
    '';
  }
