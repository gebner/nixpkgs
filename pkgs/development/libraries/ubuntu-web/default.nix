{ stdenv, fetchbzr, cmake, qtbase, qtquick1, ubuntu-ui-toolkit, oxide-qt, intltool, libapparmor, libevdev, xvfb_run, makeQtWrapper }:

stdenv.mkDerivation rec {
  name = "ubuntu-web-${version}";
  version = "2016013";

  src = fetchbzr {
    url = "lp:webbrowser-app";
    rev = 1382;
    sha256 = "0n4gdfaljsfc26s245hc8lr7fxligr31ib2xvnmsklkfszjca90d";
  };

  NIX_QT_SUBMODULE = true;

  propagatedBuildInputs = [
    cmake qtbase qtquick1 ubuntu-ui-toolkit oxide-qt
    intltool libapparmor libevdev xvfb_run
    makeQtWrapper
  ];

  cmakeFlags = [
    "-DPYTHON_PACKAGE_DIR=lib/python3.4/site-packages"
    "-DQT_INSTALL_QML=lib/qt5/qml"
  ];

  patchPhase = ''
    # one warning becomes fatal due to -Werror, so remove that flag
    # for fn in features/*.prf src/Ubuntu/Components/tools/tools.pro; do
    #   substituteInPlace $fn --replace QMAKE_CXXFLAGS '#'
    # done

    # substituteInPlace documentation/documentation.pro \
    #   --replace /usr/share $out/share

    # patchShebangs .

    substituteInPlace src/Ubuntu/CMakeLists.txt \
      --replace "OUTPUT_VARIABLE QT_INSTALL_QML" \
                "OUTPUT_VARIABLE LET_ME_OVERRIDE_YOU"

    substituteInPlace tests/autopilot/CMakeLists.txt \
      --replace 'execute_process(' 'message(STATUS '
  '';

  postFixup = ''
    wrapQtProgram $out/bin/webbrowser-app
    wrapQtProgram $out/bin/webapp-container
    wrapQtProgram $out/bin/webapp-container-hook
  '';

  enableParallelBuilding = true;
}
