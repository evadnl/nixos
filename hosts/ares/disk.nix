{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/PLACEHOLDER";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
                extraArgs = [ "-n" "BOOT" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ 
                  "-L"
                  "nixos"
                  "-f" 
                ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ 
                      "compress=zstd" 
                      "noatime" 
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ 
                      "compress=zstd" 
                      "noatime" 
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ 
                      "compress=zstd" 
                      "noatime" 
                    ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ 
                      "compress=zstd" 
                      "noatime" 
                    ];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ 
                      "compress=zstd" 
                      "noatime" 
                    ];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "36G";
                };
              };
            };
          };
        };
      };
    };
  };
}