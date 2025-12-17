{
  # user config stored in
  # ../../home/contacts.nix
  # ../../home/calendar.nix

  programs.dconf.enable = true;
  services.gnome.evolution-data-server.enable = true;
  services.gnome.gnome-online-accounts.enable = true;
}
