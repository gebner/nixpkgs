{ stdenv, python, fetchFromGitHub, cmake, swig, ninja,
  opencascade, smesh, freetype, libGL, libGLU, libX11 }:

stdenv.mkDerivation rec {
  pname = "pythonocc-core";
  version = "unstable-2019-04-30";

  src = fetchFromGitHub {
    owner = "tpaviot";
    repo = "pythonocc-core";
    # rev = version;
    rev = "595b0a4e8e60e8d6011bea0cdb54ac878efcfcd2";
    sha256 = "1fhrivhaw13lkzxdr1lyqjnddg1j9lv3cf0h86avnfbd0zg0jbl5";
  };

  nativeBuildInputs = [ cmake swig ninja ];
  buildInputs = [
    python opencascade smesh
    freetype libGL libGLU libX11
  ];

  cmakeFlags = [
    "-Wno-dev"
    "-DPYTHONOCC_INSTALL_DIRECTORY=${placeholder "out"}/${python.sitePackages}/OCC"

    "-DSMESH_INCLUDE_PATH=${smesh}/include/smesh"
    "-DSMESH_LIB_PATH=${smesh}/lib"
    "-DPYTHONOCC_WRAP_SMESH=TRUE"
  ];

  meta = with stdenv.lib; {
    description = "Python wrapper for the OpenCASCADE 3D modeling kernel";
    homepage = "https://github.com/tpaviot/pythonocc-core";
    license = licenses.lgpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ gebner ];
  };
}
