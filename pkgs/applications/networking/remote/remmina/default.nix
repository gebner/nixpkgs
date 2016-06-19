{ stdenv, fetchurl, cmake, pkgconfig, makeWrapper
, glib, gtk, gettext, libxkbfile, libgnome_keyring, libX11
, pcre, libpthreadstubs, libXdmcp, webkitgtk212x, epoxy, libappindicator-gtk3
, freerdp, libssh, libgcrypt, gnutls, makeDesktopItem }:

let
  desktopItem = makeDesktopItem {
    name = "remmina";
    desktopName = "Remmina";
    genericName = "Remmina Remote Desktop Client";
    exec = "remmina";
    icon = "remmina";
    comment = "Connect to remote desktops";
    categories = "GTK;GNOME;X-GNOME-NetworkSettings;Network;";
  };

in

stdenv.mkDerivation rec {
  name = "remmina-${version}";
  version = "1.2.0.rcgit.14";

  src = fetchurl {
    url = "https://github.com/FreeRDP/Remmina/archive/v1.2.0-rcgit.14.tar.gz";
    sha256 = "0l0h6xgfi4rwhly5pcms2s0d9yp4wrgby1l6g3rrk0s3136m9j00";
  };

  buildInputs = [ cmake pkgconfig makeWrapper pcre libpthreadstubs
                  glib gtk gettext libxkbfile libgnome_keyring libX11 libXdmcp
                  freerdp libssh libgcrypt gnutls webkitgtk212x epoxy libappindicator-gtk3 ];

  cmakeFlags = "-DWITH_VTE=OFF -DWITH_TELEPATHY=OFF -DWITH_AVAHI=OFF";

  # patches = [ ./lgthread.patch ];

  postInstall = ''
    mkdir -pv $out/share/applications
    mkdir -pv $out/share/icons
    cp ${desktopItem}/share/applications/* $out/share/applications
    cp -r $out/share/remmina/icons/* $out/share/icons
    wrapProgram $out/bin/remmina --prefix LD_LIBRARY_PATH : "${libX11.out}/lib"
  '';

  meta = with stdenv.lib; {
    license = licenses.gpl2;
    homepage = http://remmina.org/;
    description = "Remote desktop client written in GTK+";
    maintainers = with maintainers; [ gebner ];
    platforms = platforms.linux;
  };
}
