# patchance-1.3.0.nix
{
  lib,
  fetchurl,
  fetchPypi,
  python3Packages,
  libjack2,
  qt6,
  which,
  bash,
}:

let
  # Создаем python-jack пакет локально
  python-jack = python3Packages.buildPythonPackage rec {
    pname = "jack_client";
    version = "0.5.5";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-6Eggl+Ui8OLvDvuVxWYpMuiQNA+OpK1m/ON8OslghCY=";
    };

    # Для современных Python пакетов
    pyproject = true;

    nativeBuildInputs = [
      python3Packages.setuptools
    ];

    propagatedBuildInputs = [
      libjack2
      python3Packages.cffi
    ];

    # Просто отключаем все проверки
    doCheck = false;
    pythonImportsCheck = [ ];

    # Устанавливаем LD_LIBRARY_PATH для поиска libjack
    preBuild = ''
      export LD_LIBRARY_PATH=${libjack2}/lib:$LD_LIBRARY_PATH
    '';
  };
in

python3Packages.buildPythonApplication rec {
  pname = "patchance";
  version = "1.3.0";

  src = fetchurl {
    url = "https://github.com/Houston4444/Patchance/releases/download/v${version}/Patchance-${version}-source.tar.gz";
    hash = "sha256-LfRgT1uH69ePvqNwhGURS2Ixc/sLePb3qcDjZBjEzfM=";
  };

  format = "other";

  nativeBuildInputs = [
    python3Packages.pyqt6 # pyuic6 для Qt6
    qt6.qttools # lrelease для Qt6
    which
    qt6.wrapQtAppsHook # Хук для Qt6
  ];

  preBuild = ''
    export LD_LIBRARY_PATH=${libjack2}/lib:$LD_LIBRARY_PATH
  '';

  buildInputs = [
    libjack2
    bash
    qt6.qtbase # Qt6 библиотеки
  ];

  propagatedBuildInputs = [
    python3Packages.pyqt6 # PyQt6 для выполнения
    python3Packages.legacy-cgi # для модуля cgitb
    python3Packages.qtpy
    python-jack # ← Добавляем наш python-jack пакет
  ];

  dontWrapQtApps = true; # The program is a python script.

  installFlags = [ "PREFIX=$(out)" ];

  # Копируем ресурсы перед фиксацией
  preFixup = ''
    # Создаем директории для ресурсов
    mkdir -p "$out/share/patchance"

    # Копируем все ресурсы из исходников
    if [ -d "$src/HoustonPatchbay/resources" ]; then
      cp -r "$src/HoustonPatchbay/resources" "$out/share/patchance/"
    fi

    if [ -d "$src/HoustonPatchbay/themes" ]; then
      cp -r "$src/HoustonPatchbay/themes" "$out/share/patchance/"
    fi

    # Также проверяем стандартные пути
    if [ -d "$out/share/patchance/HoustonPatchbay" ]; then
      if [ -d "$out/share/patchance/HoustonPatchbay/resources" ]; then
        mkdir -p "$out/share/patchance"
        cp -r "$out/share/patchance/HoustonPatchbay/resources" "$out/share/patchance/"
      fi
      if [ -d "$out/share/patchance/HoustonPatchbay/themes" ]; then
        mkdir -p "$out/share/patchance"
        cp -r "$out/share/patchance/HoustonPatchbay/themes" "$out/share/patchance/"
      fi
    fi
  '';

  postFixup = ''
    # Сначала оборачиваем Python программы
    wrapPythonProgramsIn "$out/share/patchance/src" "$out $pythonPath"

    # Затем оборачиваем Qt программы с правильными путями
    for file in $out/bin/*; do
      wrapQtApp "$file" \
        --prefix QT_PLUGIN_PATH : "${qt6.qtbase}/${qt6.qtbase.qtPluginPrefix}" \
        --prefix QT_PLUGIN_PATH : "${qt6.qtsvg}/${qt6.qtbase.qtPluginPrefix}" \
        --prefix QML2_IMPORT_PATH : "${qt6.qtdeclarative}/${qt6.qtbase.qtQmlPrefix}" \
        --prefix XDG_DATA_DIRS : "$out/share" \
        --prefix XDG_DATA_DIRS : "${qt6.qttools}/share" \
        --prefix LD_LIBRARY_PATH : "${libjack2}/lib" \
        --prefix LD_LIBRARY_PATH : "${qt6.qtbase}/lib"
    done

    # Также создаем symlink для ресурсов если нужно
    if [ ! -e "$out/share/patchance/resources" ] && [ -d "$out/share/HoustonPatchbay/resources" ]; then
      ln -s "$out/share/HoustonPatchbay/resources" "$out/share/patchance/resources"
    fi
  '';

  makeWrapperArgs = [
    "--suffix"
    "LD_LIBRARY_PATH"
    ":"
    (lib.makeLibraryPath [
      libjack2
      qt6.qtbase
      qt6.qtsvg
      qt6.qtwayland
    ])
  ];

  meta = {
    homepage = "https://github.com/Houston4444/Patchance";
    description = "JACK Patchbay GUI";
    mainProgram = "patchance";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ orivej ];
    platforms = lib.platforms.linux;
  };
}
