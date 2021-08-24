{ 
  lib,
  buildPythonPackage,
  pytest,
  coverage,
  python-gnupg,
  pymilter,
  inShell ? false
}:
buildPythonPackage {
  pname = "pgp-milter";
  version = "0.1.dev0";
  src = ./.;
  propagatedBuildInputs = [
    pymilter
    python-gnupg
  ];
  checkInputs = [
    coverage
    pytest
  ];
  checkPhase = ''
    pytest
  '';
  doCheck = true;
  pythonImportCheck = [ "pgp_milter" ];
  meta = {
    homepage = https://github.com/ulif/pgp-milter;
    description = "Mail filter to automatically PGP encrypt messages";
    license = lib.licenses.agpl3Only;
  };
}
