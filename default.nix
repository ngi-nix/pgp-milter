{nixpkgs, pymilter}:
with nixpkgs.legacyPackages.x86_64-linux.python3Packages;
buildPythonPackage  {
  pname = "pgp-milter";
  version = "0.1.dev0";
  src = ./.;
  propagatedBuildInputs = [
    pymilter
    python-gnupg
  ];
  checkInputs = [
    pytest
    coverage
  ];
  doCheck = true;
  pythonImportCheck = ["pgp-milter"];
}
