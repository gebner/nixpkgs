{ stdenv, fetchgit, qtbase, qtdeclarative }:

stdenv.mkDerivation rec {
  name = "qtfeedback-${version}";
  version = "20150918";

  src = fetchgit {
    url = "https://code.qt.io/qt/qtfeedback.git";
    rev = "28ca62414901502189ea28ef2efd551386187619";
    sha256 = "486bd68ad47261d5699be7e2d8e231d01d7a5462a60529fa9e0ab331e61b564c";
  };

  propagatedBuildInputs = [ qtbase qtdeclarative ];
  enableParallelBuilding = true;

  NIX_QT_SUBMODULE = true;
  configurePhase = ''
    qmake
    # FIXME: figure out why syncqt is not run with make
    syncqt.pl -version 0.0.0
  '';
}
