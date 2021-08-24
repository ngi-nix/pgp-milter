{
  description = "Mail filter to automatically PGP encrypt messages";

  inputs = {
    pymilter-default-nix.url = "github:ngi-nix/pymilter";
    pymilter-1_0_4 = {
      url = "github:ngi-nix/pymilter/pymilter-1.0.4";
      flake = false;
    };
    nixpkgs.follows = "pymilter-default-nix/nixpkgs";
  };

  outputs = { self, nixpkgs, pymilter-default-nix, pymilter-1_0_4 }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [
        
        (final: prev: {
          pymilter = final.callPackage "${pymilter-default-nix.outPath}/default.nix" {
            # We change the source code of the derivation
            src = pymilter-1_0_4.outPath;
            version = "1.0.4";
            inherit (final.python3Packages) pydns bsddb3 buildPythonPackage;
          };})
          
        self.overlay

      ]; });
    in {
      overlay = final: prev: { pgp-milter = (import ./default.nix {
          inherit (final) lib pymilter;
          inherit (final.python3Packages) pytest coverage python-gnupg buildPythonPackage;
        }); };
      packages = forAllSystems (system: { inherit (nixpkgsFor.${system}) pgp-milter; });
      defaultPackage = forAllSystems (system: self.packages.${system}.pgp-milter);
      # FIXME: check also for x86_64-darwin as soon as Hydra will check darwin derivations
      checks.x86_64-linux.pgp-milter = self.packages.x86_64-linux.pgp-milter;
      devShell = forAllSystems (system: self.packages.${system}.pgp-milter.override { inShell = true; });
  };
}
