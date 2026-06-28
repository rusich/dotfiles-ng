{ pkgs, lib, ... }:

let
  rustDeps = with pkgs; [
    rustup
    # rustPlatform.bindgenHook
    # openssl
    # pkg-config
  ];
in
{
  home.packages = rustDeps;

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  # home.sessionVariables = {
  #   PKG_CONFIG_PATH = "${pkgs.openssl}/lib/pkgconfig";
  #   NIX_LD_LIBRARY_PATH = lib.makeLibraryPath (
  #     with pkgs;
  #     [
  #       openssl
  #       zlib
  #       stdenv.cc.cc.lib
  #     ]
  #   );
  # };
}
