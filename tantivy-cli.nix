{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "tantivy-cli";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "quickwit-oss";
    repo = "tantivy-cli";
    rev = version;
    hash = "sha256-+UXN0nPmXMDQSAEhADb6GNYz5WhaxV35HjQMbuUodMk=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  buildInputs =
    lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [Security]);

  meta = with lib; {
    description = "";
    homepage = "https://github.com/quickwit-oss/tantivy-cli";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
