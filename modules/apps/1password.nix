{ ... }:

{
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "evad" ];
  };

  programs._1password.enable = true;

  services.gnome.gnome-keyring.enable = true;
}
