{
  description = "Mail filter to automatically PGP encrypt messages";

  inputs.pymilter.url = "/home/jlucas/SON/Dev/pymilter";
  inputs.nixpkgs.follows = "pymilter/nixpkgs"; # to be sure to use the same nixpkgs as its dependency

  outputs = { self, nixpkgs, pymilter}:
    with nixpkgs.legacyPackages.x86_64-linux.python3Packages; {
      packages.x86_64-linux.pgp-milter = buildPythonPackage {
          pname = "pgp-milter";
          version = "0.1.dev0";
          src = ./.;
          propagatedBuildInputs = [
            pymilter.packages.x86_64-linux.pymilter
            python-gnupg
          ];
          checkInputs = [ 
            pytest
            coverage
          ];
          doCheck = true;
          pythonImportCheck = ["pgp-milter"];
      };
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.pgp-milter;
      meta.longDescription = ''
        Enables automatic PGP encryption/decryption of e-mails on the server side. It can be used with regular mailservers like postfix. It's basically a milter, that listens for input messages, then looks up PGP keys from configurable sources (local key rings, LDAP) and then, based on a local, configurable, policy, encrypts/decrypts messages (or leaves them untouched) before passing them on. This way system administrators can with tiny effort provide transparent encryption support for all their mail users.'';
    };
}
