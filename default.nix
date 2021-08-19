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
    homepage = https://github.com/ulif/pgp-milter;
    description = "Mail filter to automatically PGP encrypt messages";
    license = pkgs.lib.licenses.agpl3Only;
  };
}
