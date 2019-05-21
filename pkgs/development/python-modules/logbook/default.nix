{ stdenv, buildPythonPackage, isPy27, fetchPypi, cython, pytest, brotli, mock }:

buildPythonPackage rec {
  pname = "Logbook";
  version = "1.4.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1xgy41cys0p66600708rhki20ksj6khk0x8vss02q5yqmf96gad5";
  };

  nativeBuildInputs = [ cython ];
  checkInputs = [ pytest brotli ] ++ stdenv.lib.optional isPy27 mock;

  preBuild = ''
    # setup.py expects pre-built *.c in release tarball
    cython logbook/_speedups.pyx
  '';

  checkPhase = ''
    # setup.py test doesn't work
    py.test tests
  '';

  meta = with stdenv.lib; {
    description = "Logging system for Python that replaces the standard library's logging module";
    homepage = "https://logbook.readthedocs.io/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ gebner ];
  };
}
