## nixos-config

- After installing nixos and generating the system-specific hardware file, drop
this repo into `/etc/nixos`. The main nixos config should be owned by root.

- Run `nixos-rebuild switch` to implement the new config. 

- Give the new user a password.

- Reboot and log in.

- Run `sudo nix-channel --add https://nixos.org/channels/nixos-unstable
  unstable` to make unstable packages available.

- Get config files from github, including user-specific `nixpkgs/config.nix`.
  Run `nix-env -i custom-package-name` to install user's applications.
