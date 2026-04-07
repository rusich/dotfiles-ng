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
        "dt" = "difftool -d";
      };
      diff = {
        tool = "nvim.difftool";
        prompt = false;
      };
      difftool."nvim.difftool" = {
        cmd = "LC_ALL=C nvim -c \"packadd nvim.difftool\" -c \"DiffTool $LOCAL $REMOTE\"";
      };
      # merge = {
      #   tool = "nvimdiff";
      #   prompt = false;
      # };
      # mergetool."nvimdiff" = {
      #   cmd = "nvim -d $LOCAL $BASE $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
      # };
    };
  };
}
