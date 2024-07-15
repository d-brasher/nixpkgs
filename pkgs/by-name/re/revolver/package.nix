{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  zsh,
  installShellFiles,
  ncurses,
  nix-update-script,
}:

stdenvNoCC.mkDerivation rec {
  pname = "revolver";
  version = "0.2.4-unstable-2020-09-30";

  src = fetchFromGitHub {
    owner = "molovo";
    repo = pname;
    rev = "6424e6cb14da38dc5d7760573eb6ecb2438e9661";
    sha256 = "sha256-2onqjtPIsgiEJj00oP5xXGkPZGQpGPVwcBOhmicqKcs=";
  };

  strictDeps = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  # Test takes ~2mins
  doInstallCheck = true;

  nativeBuildInputs = [ installShellFiles ];
  propagatedBuildInputs = [
    zsh
    ncurses
  ];
  nativeInstallCheckInputs = propagatedBuildInputs;

  installPhase = ''
    runHook preInstall

    install -D revolver $out/bin/revolver

    runHook postInstall
  '';

  postInstall = ''
    installShellCompletion --cmd revolver --zsh revolver.zsh-completion
  '';

  preInstallCheck = ''
    export HOME="$TEMPDIR"
    export PATH=$PATH:$out/bin
  '';

  installCheckPhase = ''
    runHook preInstallCheck

    # Drop stdout, redirect stderr to stdout and check if it's not empty
    exec 9>&1
    if [[ $(revolver demo 2>&1 1>/dev/null | tee >(cat - >&9)) ]]; then
        exit 1
    fi

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Progress spinner for ZSH scripts";
    homepage = "https://github.com/molovo/revolver";
    downloadPage = "https://github.com/molovo/revolver/releases";
    license = lib.licenses.mit;
    mainProgram = "revolver";
    inherit (zsh.meta) platforms;
    maintainers = [ lib.maintainers.d-brasher ];
  };
}
