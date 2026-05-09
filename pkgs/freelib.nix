{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  alsa-lib,
  freetype,
  fontconfig,
  libglvnd,
  curl,
  libxcursor,
  libxinerama,
  libxrandr,
  libxrender,
  libjack2,
  wrapGAppsHook3,
  gtk3,
}:

stdenv.mkDerivation rec {
  pname = "freeLib";
  version = "6.0.93"; # Укажите актуальную версию

  # Замените URL на актуальный для tonelib-grand-magus
  src = fetchurl {
    url = "https://github.com/petrovvlad/freeLib/releases/download/v6.0.93/freeLib_6.0.93_ubuntu_2404_amd64.deb";
    hash = "sha256-wlVfRBoZ1TrzUQdp5Tczr+PQ/VtBNQp2rQ3f6PocxVs=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    wrapGAppsHook3
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    alsa-lib
    freetype
    libglvnd
    fontconfig
    gtk3
  ]
  ++ runtimeDependencies;

  runtimeDependencies = map lib.getLib [
    curl
    libxcursor
    libxinerama
    libxrandr
    libxrender
    libjack2
  ];

  unpackCmd = "dpkg -x $curSrc source";

  installPhase = ''
    mv usr $out

    # Исправляем пути в .desktop файле
    if [ -f $out/share/applications/*.desktop ]; then
      substituteInPlace $out/share/applications/*.desktop \
        --replace /usr/ $out/
    fi

    # Обёртка для запуска
    mkdir -p $out/bin
    if [ -f $out/bin/ToneLib-Grand-Magus ]; then
      wrapProgram $out/bin/ToneLib-Grand-Magus \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeDependencies}
    fi
  '';

  meta = {
    description = "Free Lib";
    homepage = "https://tonelib.net/grand-magus/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ rusich ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "ToneLib-Grand-Magus";
  };
}
