{ stdenv, fetchgit, qtbase }:

stdenv.mkDerivation rec {
  name = "qtpim-${version}";
  version = "20150212";

  src = fetchgit {
    url = "https://code.qt.io/qt/qtpim.git";
    rev = "86db658eace4dc84c1d3185c71f2282278b3a452";
    sha256 = "3e3122e68d21327f04e76a9a1e05bc5b5829fdbcaba68bc332e932a1c573a26d";
  };

  propagatedBuildInputs = [ qtbase ];
  enableParallelBuilding = true;

  patchPhase = ''
    substituteInPlace qtpim.pro --replace requires '#requires'
  '';

  NIX_QT_SUBMODULE = true;
  configurePhase = ''
    qmake
    # FIXME: figure out why syncqt is not run with make
    syncqt.pl -version 0.0.0
  '';
}
