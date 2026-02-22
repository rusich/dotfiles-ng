{
  config,
  pkgs,
  ...
}:
{
  # home.packages = with pkgs; [
  # ];

  home.file.".config/helix".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/home/helix/config";

  # All available options https://home-manager-options.extranix.com/?query=helix
  programs.helix = {
    enable = true;
  };

}
