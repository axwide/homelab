{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "flakes" "nix-command" ];

  # ── Bootloader (UEFI) ─────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Networking ────────────────────────────────────────────────────────────
  networking.hostName = "homelab";
  networking.interfaces.enp1s0.useDHCP = true;

  # ── Locale & keyboard ─────────────────────────────────────────────────────
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "sv-latin1";

  # ── User ──────────────────────────────────────────────────────────────────
  users.users.axel = {
    isNormalUser = true;
    extraGroups = [ "docker" ];
    hashedPassword = "!";  # disables password login entirely
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPDeGSqnI7KQz5U5b9QiH3EZwOw2YEvsZDpOhyACOz+r homelab"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAZ3F0EBi3J2SVNEQToGaIh51r+uqbtU5u+0C0ljnKw2 axel@EST01110925-202603"
    ];
  };

  # Disable password request on sudo use
  security.sudo.extraRules = [
    {
      users = [ "axel" ];
      commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
    }
  ];

  # ── SSH ───────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # ── Docker ────────────────────────────────────────────────────────────────
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # -- Git -------------------------------------------------------------------
  programs.git = {
    enable = true;
    config = {
      user.name = "axwide";
      user.email = "your@email.com";
    };
  };

  # ── Lid-close behavior (headless) ─────────────────────────────────────────
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  # ── Packages ──────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    docker-compose  # standalone; docker compose (plugin) also works via docker itself
  ];

  system.stateVersion = "25.11";
}
