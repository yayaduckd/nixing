{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    htop
    jq

    neovim
  ];
}
