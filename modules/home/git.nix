{ ... }:
{
  programs.lazygit.enable = true;

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
      merge = {
        tool = "nvimdiff";
        prompt = false;
      };
      mergetool."nvimdiff" = {
        cmd = "nvim -d $LOCAL $BASE $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
      };
    };
  };
}
