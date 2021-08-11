{
  description = "Mail filter to automatically PGP encrypt messages";

  inputs = {
    pymilter.url = "github:JosephLucas/pymilter";
    nixpkgs.follows = "pymilter/nixpkgs"; # to be sure to use the same nixpkgs as its dependency
  };

  outputs = { self, nixpkgs, pymilter}: let pkgs = nixpkgs.legacyPackages.x86_64-linux; in {
    packages.x86_64-linux.pgp-milter = (import ./default.nix {nixpkgs=nixpkgs; pymilter=pymilter.packages.x86_64-linux.pymilter;});
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.pgp-milter;
    devShell = pkgs.mkShell { inputsFrom = builtins.attrValues self.system; packages = [ pkgs ]; };
    meta.longDescription = ''Enables automatic PGP encryption/decryption of e-mails on the server side. It can be used with regular mailservers like postfix. It's basically a milter, that listens for input messages, then looks up PGP keys from configurable sources (local key rings, LDAP) and then, based on a local, configurable, policy, encrypts/decrypts messages (or leaves them untouched) before passing them on. This way system administrators can with tiny effort provide transparent encryption support for all their mail users.'';
  };
}
