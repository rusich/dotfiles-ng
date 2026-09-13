{
  imports = [ ../../common ];

  # Avatar for GDM / GNOME: exposed as ~/.face and ~/.face.icon.
  home.file = {
    ".face".source = ./avatar.jpg;
    ".face.icon".source = ./avatar.jpg;
  };
}
