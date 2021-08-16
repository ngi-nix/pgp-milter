{
  pkgs,
  inShell ? false
}:
with pkgs.python3Packages; buildPythonPackage {
  pname = "pgp-milter";
  version = "0.1.dev0";
  src = ./.;
  propagatedBuildInputs = [
    pkgs.pymilter
    python-gnupg
  ];
  checkInputs = [
    pytest
    coverage
  ];
  doCheck = true;
  pythonImportCheck = ["pgp-milter"];
  meta = {
    homepage = https://github.com/ehmry/pgpmilter;
    description = "Enables automatic PGP encryption/decryption of e-mails on the server side. It can be used with regular mailservers like postfix. It's basically a milter, that listens for input messages, then looks up PGP keys from configurable sources (local key rings, LDAP) and then, based on a local, configurable, policy, encrypts/decrypts messages (or leaves them untouched) before passing them on. This way system administrators can with tiny effort provide transparent encryption support for all their mail users.";
    license = pkgs.lib.licenses.agpl3Only;
  };
}
