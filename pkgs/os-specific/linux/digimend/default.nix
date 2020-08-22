{ stdenv, fetchFromGitHub, fetchpatch, kernel }:

assert stdenv.lib.versionAtLeast kernel.version "3.5";

stdenv.mkDerivation rec {
  pname = "digimend";
  version = "unstable-2020-06-22";

  src = fetchFromGitHub {
    owner = "digimend";
    repo = "digimend-kernel-drivers";
    rev = "691dae8a9fb2fdaa343fd1bf6ff79294486b2b03";
    sha256 = "087q63ayi5xi9jssl2hlplln8h3n34ykb44a6zxczsar499wq4a6";
  };

  INSTALL_MOD_PATH = "\${out}";

  postPatch = ''
    sed 's/udevadm /true /' -i Makefile
    sed 's/depmod /true /' -i Makefile
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;

  postInstall = ''
    # Remove module reload hack.
    # The hid-rebind unloads and then reloads the hid-* module to ensure that
    # the extra/ module is loaded.
    rm -r $out/lib/udev
  '';

  makeFlags = [
    "KVERSION=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "DESTDIR=${placeholder "out"}"
  ];

  meta = with stdenv.lib; {
    description = "DIGImend graphics tablet drivers for the Linux kernel";
    homepage = "https://digimend.github.io/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ gebner ];
    platforms = platforms.linux;
  };
}
