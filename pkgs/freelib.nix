{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  git,
  qt6,
  qt6Packages,
  tbb,
}:

stdenv.mkDerivation rec {
  pname = "freelib";
  version = "6.2.0";

  src = fetchFromGitHub {
    owner = "petrovvlad";
    repo = "freeLib";
    rev = "v${version}";
    hash = "sha256-kTuH8L1vZ7ktxti6InF71dPWfIr/vM4BNLQH2CJEIV8=";
  };

  smtpclient-src = fetchFromGitHub {
    owner = "petrovvlad";
    repo = "SmtpClient-for-Qt";
    rev = "master";
    hash = "sha256-W5AoHm7FCzl0MBl6KuKykHbB/+brqa5skGiu7i71chM=";
  };

  nativeBuildInputs = [
    cmake
    git
    qt6.wrapQtAppsHook
  ];

  buildInputs =
    with qt6;
    [
      qtbase
      qtsvg
      qthttpserver
    ]
    ++ [
      qt6Packages.quazip
      qt6Packages.qtkeychain
      tbb
    ];

  preConfigure = ''
    mkdir -p src/SmtpClient
    cp -r ${smtpclient-src}/* src/SmtpClient/
    rm -rf src/quazip
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=None"
    "-DFREELIB_QT_MAJOR_VERSION=6"
  ];

  meta = with lib; {
    description = "Book library manager";
    homepage = "https://github.com/petrovvlad/freeLib";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
