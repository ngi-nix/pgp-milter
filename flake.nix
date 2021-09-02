{
  description = "Mail filter to automatically PGP encrypt messages";

  inputs = {
    # as explained in requirement.txt, we want the version 1.0.4 of pymilter
    pymilter.url = "github:ngi-nix/pymilter/pymilter-1.0.4";
    nixpkgs.follows = "pymilter/nixpkgs";
  };

  outputs = { self, nixpkgs, pymilter }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [
        pymilter.outputs.overlay
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
      devShell = self.defaultPackage;
  };
}
