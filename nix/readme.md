# useful nix/nixos commands

sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable

sudo nix-channel --update


nix-env -i (software) --- installs it localy, without being in config file, like a traditional package manager


nixos-rebuild switch --- creates a new generation


---

i don't completely understand the syntax and the inner workings of nix yet so the config is highly prone to have errors in them, but it works i guess
