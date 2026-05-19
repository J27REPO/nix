{ pkgs, lib, user, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  networking.hostName = "disco";

  # GPU genérica - detección automática
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Early KMS: cargar drivers temprano
  boot.initrd.kernelModules = [ "i915" "amdgpu" ];

  # --- BOOTLOADER ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;

  # --- NETWORKING (DHCP por defecto, se adapta a cualquier red) ---
  systemd.network.wait-online.enable = false;

  # --- GRÁFICOS Y MONITOR (genérico) ---
  # Sin configuración de monitor específica - se detecta automáticamente

  # --- ZRAM ---
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 30;
  };

  # --- SWAPPINESS ---
  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkForce 10;
    "vm.watermark_scale_factor" = 125;
  };

  # --- USUARIO ---
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "docker" "input" "uinput" ];
  };

  # uinput para input devices
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess", MODE="0660", GROUP="uinput"
  '';
  users.groups.uinput = {};

  # --- SSH (para acceso remoto) ---
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Firewall básico
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # --- OPTIMIZACIONES EXTERNAS ---
  # TRIM para SSDs externos
  services.fstrim.enable = true;

  # Microcode genérico (funciona en Intel y AMD)
  hardware.cpu.intel.updateMicrocode = lib.mkForce false;
  hardware.cpu.amd.updateMicrocode = lib.mkForce false;
}