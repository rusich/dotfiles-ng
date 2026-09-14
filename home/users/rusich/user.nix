{
  fullName = "Ruslan Sergin";
  username = "rusich";
  email = "ruslan.sergin@gmail.com";

  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ7NLeqNbpkjUXCW1GVWo8nlNKhqCHIyr8qv/5UQYfPk rusich@matebook"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjQLNoxeO2BVnnYlmYWLUntVj4w2Der89NG5qm0w6u/ rusich@darkstar"
  ];

  # Console fallback password (applied as users.users.rusich.initialHashedPassword
  # only when the account is first created; SSH stays key-only). Generated with:
  #   nix shell nixpkgs#mkpasswd -c mkpasswd -m yescrypt
  # TODO(sops): switch to hashedPasswordFile backed by sops-nix.
  hashedPassword = "$y$j9T$4gso80jrhsxuikFe4L9S51$Yp6NC1tKJWv0v8vs722ObwkWRXU/DC4zwdTjUsZ3eK0";
}
