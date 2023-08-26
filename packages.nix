{
  lib,
  stdenv,
  nixpkgs,
  nix,
  runCommand,
  coreutils,
  jq,
  fzf,
  writeShellApplication,
}: rec {
  # Generate a packages.json file similar to the one provided by nixos channels.
  packages-json = runCommand "packages-json" {buildInputs = [nix];} ''
    mkdir -p $out/
    function genPackages() {
      echo "["
      mkdir store
      nix-env --store $(pwd)/store -f ${nixpkgs} -I nixpkgs=${nixpkgs} -qa --meta --json --show-trace --arg config '{ allowUnfree=true;isHydra=true;showAliases=false;}'
      echo "]"
    }
    genPackages > $out/packages.json
  '';

  # Convert it into a fzf-friendlier format, and save line number information for faster preview
  packages-fzf = runCommand "packages-fzf" {buildInputs = [coreutils jq];} ''
    mkdir -p $out/
    jq -c '.[] | to_entries[]' < ${packages-json}/packages.json > $out/packages.jsonl
    jq -r '(input_line_number | tostring) + " " + .key + " " + ((.value.meta.description // "") | gsub("[\\n\\t]"; " "))' < $out/packages.jsonl > $out/packages.txt
  '';

  fzf-nix = writeShellApplication {
    name = "fzf-nix";
    runtimeInputs = [fzf];
    text = ''
      FZF_NIX_OPTS=''${FZF_NIX_OPTS:-"--with-nth 2 --height 50%"}
      FZF_NIX_TEMPLATE=''${FZF_NIX_TEMPLATE:-'.key + " (" + .value.version + ")\n" + .value.meta.homepage + "\n\n" + .value.meta.description'}
      # shellcheck disable=SC2086
      # FZF_NIX_OPTS expanded on purpose
      fzf $FZF_NIX_OPTS "$@" --preview-window wrap --preview "head -n {1} ${packages-fzf}/packages.jsonl | tail -n 1 | jq -r '$FZF_NIX_TEMPLATE'" < ${packages-fzf}/packages.txt  |
        awk '{ print $2 }' | xargs echo -n
    '';
  };

  default = fzf-nix;
}
