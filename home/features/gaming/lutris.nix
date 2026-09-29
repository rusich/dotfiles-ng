{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.gaming.lutris;

  retroarchWithCores = pkgs.retroarch.withCores (
    cores: with cores; [
      fceumm
      gambatte
      genesis-plus-gx
      nestopia
      snes9x
    ]
  );

  runnersDir = "${config.home.homeDirectory}/.local/share/lutris/runners";
  retroarchConfigDir = "${config.home.homeDirectory}/.config/retroarch";
in
{
  options.user.gaming.lutris.enable =
    lib.mkEnableOption "Lutris wired to NixOS emulator packages (RPCS3, Ryujinx, libretro)";

  config = lib.mkIf cfg.enable {
    # Lutris treats a runner as installed when its executable (and, for
    # libretro, the selected core) exists under RUNNER_DIR. Symlink the
    # NixOS-packaged emulators there instead of letting Lutris download
    # unmanaged binaries into $HOME.
    home.activation.lutrisRunners = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "${runnersDir}/ryujinx/publish" "${runnersDir}/rpcs3" "${runnersDir}/retroarch"
      run ln -sfn "${pkgs.ryubing}/bin/ryujinx" "${runnersDir}/ryujinx/publish/Ryujinx"
      run ln -sfn "${pkgs.rpcs3}/bin/rpcs3" "${runnersDir}/rpcs3/rpcs3"
      run ln -sfn "${retroarchWithCores}/bin/retroarch" "${runnersDir}/retroarch/retroarch"
      run ln -sfn "${retroarchWithCores}/lib/retroarch/cores" "${runnersDir}/retroarch/cores"
      run ln -sfn "${pkgs.retroarch-joypad-autoconfig}/share/libretro/autoconfig" "${runnersDir}/retroarch/autoconfig"
      run rm -rf "${runnersDir}/retroarch/info"
      run mkdir -p "${runnersDir}/retroarch/info"
      run ln -sfn "${pkgs.libretro-core-info}/share/retroarch/cores/fceumm_libretro.info" "${runnersDir}/retroarch/info/fceumm_libretro.info"
      run ln -sfn "${pkgs.libretro-core-info}/share/retroarch/cores/gambatte_libretro.info" "${runnersDir}/retroarch/info/gambatte_libretro.info"
      run ln -sfn "${pkgs.libretro-core-info}/share/retroarch/cores/genesis_plus_gx_libretro.info" "${runnersDir}/retroarch/info/genesis_plus_gx_libretro.info"
      run ln -sfn "${pkgs.libretro-core-info}/share/retroarch/cores/nestopia_libretro.info" "${runnersDir}/retroarch/info/nestopia_libretro.info"
      run ln -sfn "${pkgs.libretro-core-info}/share/retroarch/cores/snes9x_libretro.info" "${runnersDir}/retroarch/info/snes9x_libretro.info"
      run mkdir -p "${retroarchConfigDir}"
      run ln -sfn "${retroarchWithCores}/lib/retroarch/cores" "${retroarchConfigDir}/cores"
      run ln -sfn "${runnersDir}/retroarch/info" "${retroarchConfigDir}/info"
    '';
  };
}
