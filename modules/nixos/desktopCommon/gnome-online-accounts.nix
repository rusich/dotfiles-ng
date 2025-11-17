{ pkgs, ... }:
{
  # Надо создать конфигурационный файл онлайн-аккаунта Nextcloud ~/.config/goa-1.0/accounts.conf :
  # Детали: ~/Nextcloud/org/notes/Gnome_online_accounts-20250217.org

  programs.dconf.enable = true;
  services.gnome.evolution-data-server.enable = true;
  services.gnome.gnome-online-accounts.enable = true;
}
