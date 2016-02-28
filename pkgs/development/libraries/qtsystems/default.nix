{ stdenv, fetchgit, qtbase, qtdeclarative }:

stdenv.mkDerivation rec {
  name = "qtsystems-${version}";
  version = "20160205";

  src = fetchgit {
    url = "https://code.qt.io/qt/qtsystems.git";
    rev = "cc2077700bd5503d1fcf53aef83cbb76975e745a";
    sha256 = "7320180ac9e65a1b2dcccea58ccbe415ee80c3a42d4fcf5b4fc032c6892d0782";
  };

  propagatedBuildInputs = [ qtbase qtdeclarative ];
  enableParallelBuilding = true;

  NIX_QT_SUBMODULE = true;
  configurePhase = ''
    qmake
    # FIXME: figure out why syncqt is not run with make
    syncqt.pl -version 5.4.0
  '';
}
