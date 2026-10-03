{ primaryUser, config, ... }:
{
  programs.lazygit.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = primaryUser.fullName;
        email = primaryUser.email;
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
      merge = {
        tool = "nvimdiff2";
        prompt = false;
        conflictStyle = "zdiff3";
      };
      mergetool = {
        keepBackup = false;
        # Ask "Was the merge successful?" if the file was left unchanged
        # (e.g. quitting nvim with :q!), so an untouched file stays unmerged.
        "nvimdiff2" = {
          trustExitCode = false;
        };
      };
      # Strip the KeeShare private key from keepassxc.ini before committing.
      # Inert unless .gitattributes marks a file with filter=strip-keeshare.
      filter."strip-keeshare" = {
        clean = "sh ${config.dotfilesPath}/scripts/strip-keeshare.sh";
        smudge = "cat";
      };
    };
  };
}
