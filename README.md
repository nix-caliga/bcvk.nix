## **This patch was mostly written by AI, thankfully there isn't much that you need to review.**

[Bcvk](https://github.com/bootc-dev/bcvk) patched to run on NixOS

## Example usage

```
nix run github:nix-caliga/bcvk.nix -- ephemeral run-ssh quay.io/fedora/fedora-bootc:44
```
Drops into a shell with `bcvk`
```
nix develop github:nix-caliga/bcvk.nix
```

## libvirt

`bcvk libvirt` requires some host configuration, such as:
```nix
virtualisation.libvirtd = {
  enable = true;
  qemu.vhostUserPackages = [ pkgs.virtiofsd ]; # lets libvirt find virtiofsd
  qemu.swtpm.enable = true; # bcvk adds a TPM to every VM (or pass --disable-tpm)
};
environment.systemPackages = [ pkgs.swtpm ];
users.users.<you>.extraGroups = [ "libvirtd" ];
```
