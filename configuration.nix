{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ── Bootloader (UEFI) ─────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Fix Realtek RTL8111/8168 NIC driver conflict ──────────────────────────
  # Replaces the r8169 workaround you do post-install on Ubuntu
  # boot.extraModulePackages = [ config.boot.kernelPackages.r8168 ];
  # boot.blacklistedKernelModules = [ "r8169" ];

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

  # ── Lid-close behavior (headless) ─────────────────────────────────────────
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  # ── Packages ──────────────────────────────────────────────────────────────
  # No snapd to purge — it simply doesn't exist on NixOS
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    ansible
    docker-compose  # standalone; docker compose (plugin) also works via docker itself
  ];

  system.stateVersion = "24.11";
}
