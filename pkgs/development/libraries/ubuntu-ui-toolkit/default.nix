{ stdenv, fetchbzr, qtbase, qtquick1, qtdeclarative, qtgraphicaleffects, qtquickcontrols, qtpim, qtfeedback,
  pkgconfig, perl, libnih, dbus, gettext, lttng-ust, liburcu }:

stdenv.mkDerivation rec {
  name = "ubuntu-ui-toolkit-${version}";
  version = "2016013";

  src = fetchbzr {
    url = "lp:ubuntu-ui-toolkit";
    rev = 1280;
    sha256 = "0n6a7r36wv9pxm0c8hqnznwmhfv5aq5rvjxmyfl4dgxhg48n3ram";
  };

  NIX_QT_SUBMODULE = true;

  propagatedBuildInputs = [
    qtbase qtquick1 qtdeclarative qtgraphicaleffects qtquickcontrols qtpim qtfeedback
    pkgconfig perl libnih dbus gettext lttng-ust liburcu
  ];

  patchPhase = ''
    # one warning becomes fatal due to -Werror, so remove that flag
    for fn in features/*.prf src/Ubuntu/Components/tools/tools.pro; do
      substituteInPlace $fn --replace QMAKE_CXXFLAGS '#'
    done

    substituteInPlace documentation/documentation.pro \
      --replace /usr/share $out/share

    patchShebangs .
  '';

  configurePhase = "qmake QTREPOS=$qtOut/lib/qt5";

  enableParallelBuilding = true;
}
