{ qtSubmodule, python, qtbase, qtsvg, qtxmlpatterns }:

qtSubmodule {
  name = "qtdeclarative";
  patches = [
    ./0001-nix-profiles-import-paths.patch
    ./0002-qmlplugin.patch
  ];
  qtInputs = [ qtbase qtsvg qtxmlpatterns ];
  nativeBuildInputs = [ python ];
}
