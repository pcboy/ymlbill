{
  description = "ymlbill development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        ruby = pkgs.ruby_3_4;
        rubyPackages = pkgs.rubyPackages_3_4;

        gems = pkgs.bundlerEnv {
          name = "ymlbill-gems";
          inherit ruby;
          gemdir = ./.;
        };

        version = pkgs.lib.removePrefix "Ymlbill::VERSION = '" (
          pkgs.lib.removeSuffix "'\n" (pkgs.lib.readFile ./lib/ymlbill/version.rb)
        );

        ymlbill_gem = pkgs.buildRubyGem {
          gemName = "ymlbill";
          inherit version ruby;
          src = ./.;
          propagatedBuildInputs = [ gems ];
        };

        ymlbill =
          pkgs.runCommand "ymlbill"
            {
              nativeBuildInputs = [ pkgs.makeWrapper ];
            }
            ''
              mkdir -p $out/bin
              cp ${ymlbill_gem}/bin/ymlbill $out/bin/
              wrapProgram $out/bin/ymlbill \
                --prefix PATH : ${
                  lib.makeBinPath (
                    with pkgs;
                    [
                      chromium
                      fontconfig
                      dejavu_fonts
                    ]
                  )
                } \
                --set BROWSER_PATH ${lib.getExe pkgs.chromium}
            '';
      in
      {
        packages.default = ymlbill;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            gems
            (lib.lowPrio gems.wrappedRuby)
            rubyPackages.solargraph
            bashInteractive

            (bundix.override {
              bundler = bundler.override {
                inherit ruby;
              };
            })
            (bundler.override { inherit ruby; })

            # Chromium and fonts for Ferrum
            chromium
            fontconfig
            dejavu_fonts
          ];

          env = {
            BROWSER_PATH = lib.getExe pkgs.chromium;
          };

          shellHook = ''
            export RUBYLIB="$PWD/lib:''${RUBYLIB:-}"
            export PATH="$PWD/exe:$PATH"
          '';
        };
      }
    );
}
