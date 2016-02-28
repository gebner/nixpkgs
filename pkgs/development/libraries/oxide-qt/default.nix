{ stdenv, fetchurl, qt55, ninja, gettext, pkgconfig, python, which,
  pciutils, dbus, fontconfig, pango, nss, nspr, gdk_pixbuf, libpulseaudio,
  libkrb5, libnotify, gperf, bison, alsaLib, cmake, xorg,
  bzip2, flac, speex, libopus, libevent, expat, libjpeg, snappy,
  libpng, libxml2, libxslt, libcap, xdg_utils, yasm, minizip, libwebp, libusb1, libexif }:

let
  gypFlags = {
    linux_use_bundled_binutils = false;
    linux_use_bundled_gold = false;
    linux_use_gold_binary = false;
    linux_use_gold_flags = false;
    proprietary_codecs = false;
    # use_sysroot = false;
    # use_gnome_keyring = gnomeKeyringSupport;
    # use_gconf = gnomeSupport;
    # use_gio = gnomeSupport;
    # use_pulseaudio = pulseSupport;
    # linux_link_pulseaudio = pulseSupport;
    # disable_nacl = !enableNaCl;
    # enable_hotwording = enableHotwording;
    # selinux = enableSELinux;
    # use_cups = cupsSupport;

    use_system_bzip2 = true;
    use_system_flac = true;
    use_system_libevent = true;
    use_system_libexpat = true;
    use_system_libexif = true;
    use_system_libjpeg = true;
    use_system_libpng = true;
    use_system_libwebp = true;
    use_system_libxml = true;
    use_system_opus = true;
    use_system_snappy = true;
    use_system_speex = true;
    use_system_stlport = true;
    use_system_xdg_utils = true;
    use_system_yasm = true;
    use_system_zlib = false;
    use_system_protobuf = false; # needs newer protobuf

    use_system_harfbuzz = false;
    use_system_icu = false; # Doesn't support ICU 52 yet.
    use_system_libusb = false; # http://crbug.com/266149
    use_system_skia = false;
    use_system_sqlite = false; # http://crbug.com/22208
    use_system_v8 = false;
  };

  addGypFlags =
    with stdenv.lib; let
      sanitize = value:
        if value == true then "1"
        else if value == false then "0"
        else "${value}";
      toFlag = key: value: "-D${key}=${sanitize value}";
      toCMakePatchCommand = key: value: ''
        echo "list(APPEND OXIDE_GYP_EXTRA_ARGS ${toFlag key value})" >> qt/config.cmake
      '';
    in attrs: concatStringsSep "" (attrValues (mapAttrs toCMakePatchCommand attrs));

in stdenv.mkDerivation rec {
  name = "oxide-qt-${version}";
  version = "1.12.7";

  src = fetchurl {
    url = "http://archive.ubuntu.com/ubuntu/pool/main/o/oxide-qt/oxide-qt_${version}.orig.tar.xz";
    sha256 = "1b033i1dhha8d53bxkgaa1jmg2rildm9gjizcvm3jd9dylsj5mf8";
  };

  buildInputs = [
    qt55.qtbase qt55.qtlocation
    ninja gettext pkgconfig python which
    pciutils dbus fontconfig pango nss nspr gdk_pixbuf libnotify gperf bison
    alsaLib libpulseaudio cmake libkrb5

    # chromium system dependencies
    bzip2 flac speex (libopus.override { withCustomModes = true; })
    libevent expat libjpeg snappy
    libpng libxml2 libxslt libcap
    xdg_utils yasm minizip libwebp
    libusb1 libexif
  ] ++ (with xorg; [ libX11 libXi libXcursor libXcomposite libXdamage libXext libXrandr libXtst ]);

  patchPhase = ''
    sed -i s,/bin/echo,echo,g `find -name '*.gyp*'`

    substituteInPlace qt/qmlplugin/CMakeLists.txt \
      --replace "OUTPUT_VARIABLE QT_INSTALL_QML" \
                "OUTPUT_VARIABLE LET_ME_OVERRIDE_YOU" \
      --replace LD_LIBRARY_PATH= 'LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:'

    # substituteInPlace CMakeLists.txt \
    #   --replace 'set(CMAKE_SKIP_BUILD_RPATH' '#'

    ${addGypFlags gypFlags}

    # Related to issue #1963
    # substituteInPlace CMakeLists.txt --replace '-fuse-ld=gold' ""
    # substituteInPlace build/common.gypi --replace "'linux_use_gold_flags': 1," ""
  '';

  postConfigure = ''
    # Linker flags in response files are ignored, see issue #11762
    # This disables the use of response files for the linker
    substituteInPlace out/chromium/Release/build.ninja \
      --replace 'rspfile' '#rspfile' \
      --replace '@$link_file_list' '-Wl,--whole-archive $in $solibs -Wl,--no-whole-archive $libs'
  '';

  cmakeFlags = [
    "-DENABLE_HYBRIS=0"
    "-DQT_INSTALL_QML=lib/qt5/qml"
  ];

  postInstall = ''
    chmod +x $out/lib64/libOxideQtCore.so.0
    # exit 1
  '';
}
