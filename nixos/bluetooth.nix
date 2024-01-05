
{config, lib, pkgs, ...}: 
let
  bluepair = pkgs.writeShellScriptBin "bluepair" ''
    # Check if the timeout argument is provided
    if [ "$#" -eq 0 ]; then
        echo "Usage: $0 <timeout>"
        exit 1
    fi

    timeout_value="$1"

    # Run Bluetooth scan and extract the third column
    devices=$(bluetoothctl --timeout "$timeout_value" scan on | awk '{print $3}')

    # Use ripgrep (rg) to filter the desired device
    selected_device=$(echo "$devices" | rg "C3:3A:DC")

    # If a matching device is found, pair using bluetoothctl
    if [ -n "$selected_device" ]; then
        bluetoothctl pair "$selected_device"
    else
        echo "Device not found or pairing failed."
    fi
  '';

in
{
  config = lib.mkIf config.rot-nixos.bluetooth.enable {
    # Bluetooth
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      package = pkgs.bluez;  
      settings = {
        General.Enable = "Source,Sink,Media,Socket";
        General.DiscoverableTimeout = 0;
        General.Name = "G604 LIGHTSPEED";
        General.ControllerMode = "dual";
        Policy.AutoEnable = true;
      };
    };
    services.blueman.enable = true;
    environment.systemPackages = [pkgs.bluedevil];

    hm.home.packages = [
      bluepair
    ];
  };

}
