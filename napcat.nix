{ pkgs, lib, ... }:
let
  napcat_version = "2.6.23";
  qq_version = "3.2.12_240927";

  sources = {
    napcat_url = "https://github.com/NapNeko/NapCatQQ/releases/download/v${napcat_version}/NapCat.Shell.zip";
    napcat_hash = "sha256-lLBPVKRBc4LGWMDQOIX9A0HBP0htM1D3XT0YJgJgrSo=";
    qq_amd64_url = "https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_${qq_version}_amd64_01.deb";
    qq_amd64_hash = "sha256-xBGSSxXDu+qUwj203i3iAkfI97iLtGOuGMGfEU6kCyQ=";
    qq_arm64_url = "https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_${qq_version}_arm64_01.deb";
    qq_arm64_hash = "sha256-VfM+p2cTNkDZc7sTftfTuRSMKVWwE6TerW25pA1MIR0=";
  };
  napcat-shell-zip = pkgs.fetchurl {
    url = sources.napcat_url;
    hash = sources.napcat_hash;
  };

  srcs = {
    x86_64-linux = pkgs.fetchurl {
      url = sources.qq_amd64_url;
      hash = sources.qq_amd64_hash;
    };
    aarch64-linux = pkgs.fetchurl {
      url = sources.qq_arm64_url;
      hash = sources.qq_arm64_hash;
    };
  };

  currentSystem = pkgs.stdenv.hostPlatform.system;
  src = srcs.${currentSystem} or (throw "Unsupported system: ${currentSystem}");
  patched = pkgs.qq.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ pkgs.unzip ]; # 添加 unzip 到依赖中
    version = "3.2.12-2024.9.27";
    inherit src;
    postFixup = ''
      mkdir -p $out/opt/QQ/resources/app/napcat
      napcat_dir=$out/opt/QQ/resources/app/napcat
      unzip ${napcat-shell-zip} -d $napcat_dir
      rm -rf $out/opt/QQ/resources/app/package.json
      mv $napcat_dir/qqnt.json $out/opt/QQ/resources/app/package.json
      rm $napcat_dir/loadNapCat.js
      echo "import os$1 from 'os';
      (async () => {await import(os$1.homedir() + '/.config/napcat/napcat.mjs');})();" > $out/opt/QQ/resources/app/loadNapCat.js
    '';
    meta = { };
  });
in
(pkgs.writeShellApplication {
  name = "napcat";
  runtimeInputs = [ patched pkgs.coreutils ];
  text = ''
    if [ ! -d "$HOME/.config/napcat" ]; then
      mkdir -p "$HOME/.config"
      cp -r ${patched}/opt/QQ/resources/app/napcat "$HOME/.config"
      chmod -R u+w "$HOME/.config/napcat"
      echo "Directory $HOME/.config/napcap created."
    fi
    exec qq --no-sandbox
  '';
  meta = { };
})
  
