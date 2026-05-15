_:

{
  # ── Bluetooth ───────────────────────────────────────────────────────────
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true; # Battery level reporting
      FastConnectable = true;
    };
  };

  services.blueman.enable = true;
}
