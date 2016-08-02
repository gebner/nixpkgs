{ stdenv, fetchFromGitHub, rustPlatform }:

with rustPlatform;

buildRustPackage rec {
  name = "tokei-${version}";
  version = "4.0.0";
  src = fetchFromGitHub {
    owner = "Aaronepower";
    repo = "tokei";
    rev = "0f44c5b291ff8097b9c2589debeda31f5bc93860";
    sha256 = "18l3sljdgscyq1zzcwrxmsrpaq2i0rzkcq7gpdwhz01rnymlfi3q";
  };

  depsSha256 = "1syx8qzjn357dk2bf4ndmgc4zvrglmw88qiw117h6s511qyz8z0z";

  installPhase = ''
    mkdir -p $out/bin
    cp -p target/release/tokei $out/bin/
  '';

  meta = with stdenv.lib; {
    description = "Count code, quickly";
    homepage = https://github.com/Aaronepower/tokei;
    license = licenses.mit;
    maintainers = with maintainers; [ gebner ];
    platforms = platforms.all;
  };
}
