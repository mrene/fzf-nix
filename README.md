<h1 align="center">fzf-nix</h1>

## What does it do?
Fuzzy search through nixpkgs.

## Usage
![asciicast](./docs/term.svg)

fzf-nix can be added to your configuration and will generate the package list from the nixpkgs input.

Try it out with `nix run github:mrene/fzf-nix`

```nix
{
  inputs.fzf-nix = {
      url = "github:mrene/fzf-nix";
      fzf-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
}
```
