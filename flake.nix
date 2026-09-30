{
  description = "Bcvk with nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      bcvk = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
        pname = "bcvk";
        version = "0.19.0";

        src = pkgs.fetchFromGitHub {
          owner = "bootc-dev";
          repo = "bcvk";
          tag = "v${finalAttrs.version}";
          hash = "sha256-Kwt2n5fpZsdD6IoE+J3woZjF0w+y52VxteT2q+f/8KM=";
        };

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

        cargoHash = "sha256-ydFJwQ1jtShaP4A+qKqfKRgjPqUAXk59KMJ06vd5jek=";

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
      });
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
