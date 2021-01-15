{ lib, stdenv, mkDerivation, fetchFromGitHub, pkgconfig
, libXtst, libvorbis, hunspell, lzo, xz, bzip2, libiconv
, qtbase, qtsvg, qtwebkit, qtx11extras, qttools, qmake
, withCC ? true, opencc
, withEpwing ? true, libeb
, withExtraTiff ? true, libtiff
, withFFmpeg ? true, libao, ffmpeg_3
, withMultimedia ? true
, withZim ? true, zstd }:

mkDerivation rec {
  pname = "goldendict";
  version = "2020-12-09";

  src = fetchFromGitHub {
    owner = "goldendict";
    repo = pname;
    rev = "261e45a5d79f9df2fbc050292410bed0f4ef3132";
    sha256 = "01pny06d4cmwf998hpqd7xx7mccbbasb8js1bv3rkdi1ljg01f7n";
  };

  patches = [
    ./0001-dont-check-for-updates.patch
  ] ++ lib.optionals stdenv.isDarwin [
    ./0001-dont-use-maclibs.patch
  ];

  postPatch = ''
    substituteInPlace goldendict.pro \
      --replace "hunspell-1.6.1" "hunspell-${lib.versions.majorMinor hunspell.version}"
  '';

  nativeBuildInputs = [ pkgconfig qmake ];
  buildInputs = [
    qtbase qtsvg qtwebkit qttools
    libvorbis hunspell xz lzo
  ] ++ lib.optionals stdenv.isLinux [ qtx11extras libXtst ]
    ++ lib.optionals stdenv.isDarwin [ bzip2 libiconv ]
    ++ lib.optional withCC opencc
    ++ lib.optional withEpwing libeb
    ++ lib.optional withExtraTiff libtiff
    ++ lib.optionals withFFmpeg [ libao ffmpeg_3 ]
    ++ lib.optional withZim zstd;

  qmakeFlags = with lib; [
    "goldendict.pro"
    (optional withCC "CONFIG+=chinese_conversion_support")
    (optional (!withCC) "CONFIG+=no_chinese_conversion_support")
    (optional (!withEpwing) "CONFIG+=no_epwing_support")
    (optional (!withExtraTiff) "CONFIG+=no_extra_tiff_handler")
    (optional (!withFFmpeg) "CONFIG+=no_ffmpeg_player")
    (optional (!withMultimedia)"CONFIG+=no_qtmultimedia_player")
    (optional withZim "CONFIG+=zim_support")
  ];

  postInstall = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    mv GoldenDict.app $out/Applications
    wrapQtApp $out/Applications/GoldenDict.app/Contents/MacOS/GoldenDict
  '';

  meta = with lib; {
    homepage = "http://goldendict.org/";
    description = "A feature-rich dictionary lookup program";
    platforms = with platforms; linux ++ darwin;
    maintainers = with maintainers; [ gebner astsmtl sikmir ];
    license = licenses.gpl3Plus;
  };
}
