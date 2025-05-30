{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "joshuto";
  version = "0.9.8-unstable-2024-07-20";

  src = fetchFromGitHub {
    owner = "kamiyaa";
    repo = "joshuto";
    rev = "d10ca32f8a2fea1afb6a5466b7dd29513066c996";
    hash = "sha256-T5NfPPl8bAp3pcY1A7Dm37wC3+xrtYdoGEe4QOYgwUw=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-By7vwdNocNDQAbeD6CUcp0OOlqs5oZ2WLdE4VHSh3cI=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd joshuto \
      --bash <($out/bin/joshuto completions bash) \
      --zsh <($out/bin/joshuto completions zsh) \
      --fish <($out/bin/joshuto completions fish)
  '';

  meta = with lib; {
    description = "Ranger-like terminal file manager written in Rust";
    homepage = "https://github.com/kamiyaa/joshuto";
    changelog = "https://github.com/kamiyaa/joshuto/releases/tag/${src.rev}";
    license = licenses.lgpl3Only;
    maintainers = with maintainers; [
      figsoda
      totoroot
      xrelkd
    ];
    mainProgram = "joshuto";
  };
}
