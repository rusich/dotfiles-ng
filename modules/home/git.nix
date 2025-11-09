{
  config,
  pkgs,
  userSettings,
  ...
}:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Ruslan Sergin";
        email = "ruslan.sergin@gmail.com";
      };
      init.defaultBranch = "main";
      alias = {
        "pr" = "pull --rebase";
      };
    };
  };
}
