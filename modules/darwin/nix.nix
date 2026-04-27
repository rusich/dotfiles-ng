{
  ...
}:
{
  # Nix configuration specific for darwin

  nix = {
    optimise.automatic = true; # sheduled
    # cleanup system automatically
    gc = {
      interval = [
        {
          Hour = 3;
          Minute = 15;
          Weekday = 7;
        }
      ];
    };
  };
}
