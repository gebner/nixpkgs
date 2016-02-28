{ qtSubmodule, qtdeclarative }:

qtSubmodule {
  name = "qtgraphicaleffects";
  qtInputs = [ qtdeclarative ];
  postInstall = ''
    # make sure we're recognized as a qt submodule
    touch $out/mkspecs/.keep
  '';
}
