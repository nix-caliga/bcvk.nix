{
  description = "Bcvk with nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    bcvk-src = {
      url = "github:bootc-dev/bcvk/b2c597d1d6906bc0da57ba90b83b3f35f2525c6d";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, bcvk-src, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      bcvk = pkgs.rustPlatform.buildRustPackage {
        pname = "bcvk";
        version = "0.19.0";

        src = bcvk-src;

        patches = [ ./bcvk.patch ];

        env = {
          BCVK_NIX_TOOL_PATH = pkgs.lib.makeBinPath [
            pkgs.qemu
            pkgs.systemd
            pkgs.binutils-unwrapped
            pkgs.openssh
            pkgs.util-linux
          ];
        };

        postInstall = ''
          wrapProgram $out/bin/bcvk \
            --set-default VIRTIOFSD_BIN ${pkgs.virtiofsd}/bin/virtiofsd \
            --suffix PATH : ${
              pkgs.lib.makeBinPath [
                pkgs.which
                pkgs.python3Packages.virt-firmware
              ]
            }
        '';

        cargoHash = "sha256-VxAtLTtxvJspTHfInSguKLH8W8kZ5Orzd2oH7kv2OG0=";

        buildAndTestSubdir = "crates/kit";
        nativeBuildInputs = [
          pkgs.pkg-config
          pkgs.makeWrapper
        ];
        buildInputs = [ pkgs.openssl ];

        doCheck = false;

        meta = {
          description = "bootc virtualization kit, patched for NixOS";
          homepage = "https://github.com/bootc-dev/bcvk";
          license = with pkgs.lib.licenses; [
            asl20
            mit
          ];
          mainProgram = "bcvk";
        };
      };
    in
    {
      packages.${system} = {
        default = bcvk;
        bcvk = bcvk;
      };

      devShells.${system}.default = pkgs.mkShell {
        name = "bcvk";

        packages = [
          bcvk
        ];

        shellHook = ''
          echo "bcvk version: $(bcvk --version)"
        '';
      };
    };
}
