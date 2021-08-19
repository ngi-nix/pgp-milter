{
  description = "Mail filter to automatically PGP encrypt messages";

  inputs = {
    pymilter.url = "github:ngi-nix/pymilter";
    nixpkgs.follows = "pymilter/nixpkgs"; # to be sure to use the same nixpkgs as its dependency
  };

  outputs = { self, nixpkgs, pymilter}:
    let 
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [
        pymilter.overlay 
        self.overlay 
      ]; });
    in {
      overlay = final: prev: { pgp-milter = (import ./default.nix { pkgs = final; }); };
      packages = forAllSystems (system: { inherit (nixpkgsFor.${system}) pgp-milter; });
      defaultPackage = forAllSystems (system: self.packages.${system}.pgp-milter);
      # FIXME: check also for x86_64-darwin as soon as Hydra will check darwin derivations
      checks.x86_64-linux.pgp-milter = self.packages.x86_64-linux.pgp-milter;
      devShell = forAllSystems (system: self.packages.${system}.pgp-milter.override { inShell = true; });
  };
}
