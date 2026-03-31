{ ... }:

{
  programs.mangohud = {
    enable = true;
    settings = {
      fps = true;
      gpu_stats = true;
      gpu_temp = true;
      cpu_stats = true;
      cpu_temp = true;
      ram = true;
      frame_timing = true;
      position = "top-left";
    };
  };
}
