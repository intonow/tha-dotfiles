# useful nix/nixos commands

sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable

sudo nix-channel --update


nix-env -i (software) --- installs it localy, without being in config file, like a traditional package manager


nixos-rebuild switch --- creates a new generation


TODO :

- understand flakes ( or at least a little bit )

- fix the fonts for flatpak and declaratively
