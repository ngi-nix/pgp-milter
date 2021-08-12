{
  description = "Mail filter to automatically PGP encrypt messages";

  inputs = {
    pymilter.url = "github:JosephLucas/pymilter";
    nixpkgs.follows = "pymilter/nixpkgs"; # to be sure to use the same nixpkgs as its dependency
  };

  outputs = { self, nixpkgs, pymilter}: let pkgs = nixpkgs.legacyPackages.x86_64-linux; in {
    packages.x86_64-linux.pgp-milter = (import ./default.nix {
      nixpkgs=nixpkgs; 
      pymilter=pymilter.packages.x86_64-linux.pymilter;
    });
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.pgp-milter;
    checks.x86_64-linux.pgp-milter = self.packages.x86_64-linux.pgp-milter;
    devShell.x86_64-linux = pkgs.mkShell {
      inputsFrom = builtins.attrValues self.inputs;
      packages = [ self.packages.x86_64-linux.pgp-milter ];
    };
  };
}
