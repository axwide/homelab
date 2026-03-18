{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "flakes" "nix-command" ];

  environment.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake /home/axel/homelab#homelab";
  };

  # Set up folders
  systemd.tmpfiles.rules = [
    "d /home/axel/media/ 0755 axel users -"
    "d /home/axel/media/downloads 0755 axel users -"
  ];

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
    extraGroups = [ "docker" "wheel"];
    hashedPassword = "!";  # disables password login entirely
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6ySHMxxYROXbTJL3H3sk2PDcAOoWBLxPVQ/EGU8kGU axel@desktop-wsl-202603"
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

  # ── Tailscale ─────────────────────────────────────────────────────────────
  services.tailscale.enable = true;

  # ── Git ───────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    config = {
      user.name = "Axel";
      user.email = "afgwidenfelt@gmail.com";
      credential.helper = "store";
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
    lazygit
    sops
    age
  ];

  # ── Secrets (sops-nix) ───────────────────────────────────────────────────
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      nordvpn_token = {};
      # future secrets go here
    };

    templates."docker.env" = {
      owner = "axel";
      content = ''
        NORDVPN_TOKEN=${config.sops.placeholder.nordvpn_token}
      '';
    };
  };

  # ── Automatic updates ──────────────────────────────────────────────────────────────

  systemd.services.homelab-upgrade = {
    description = "Pull latest config from GitHub and rebuild";
    path = with pkgs; [ git nixos-rebuild nix ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      WorkingDirectory = "/home/axel/homelab";
      ExecStart = "${pkgs.bash}/bin/bash -c 'git -C /home/axel/homelab pull --ff-only && nixos-rebuild switch --flake /home/axel/homelab#homelab'";
    };
  };

  systemd.timers.homelab-upgrade = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Wed 06:00";  # after the GH Action has had time to run
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };

  system.stateVersion = "25.11";
}
