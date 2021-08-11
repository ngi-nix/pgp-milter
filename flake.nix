{
  description = "Mail filter to automatically PGP encrypt messages";

  inputs.pymilter.url = "/home/jlucas/SON/Dev/pymilter";
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.nixpkgs.follows = "pymilter/nixpkgs"; # to be sure to use the same nixpkgs

  outputs = { self, nixpkgs, pymilter}:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    rec {
      packages.x86_64-linux.pgp-milter = pkgs.python3Packages.buildPythonPackage {
          pname = "pgp-milter";
          version = "0.1.dev0";
          src = ./.;
          propagatedBuildInputs = [
            pymilter.packages.x86_64-linux.pymilter
            pkgs.python3Packages.python-gnupg
          ];
          checkInputs = [ 
            pkgs.python3Packages.pytest
            pkgs.python3Packages.coverage
          ];
          doCheck = true;
          pythonImportCheck = ["pgp-milter"];
      };
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.pgp-milter;
    };
}
