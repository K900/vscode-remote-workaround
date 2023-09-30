{
  description = "Absolutely minimal VSCode remote workaround, primarily for WSL systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    ...
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    nixosModules.default = import ./vscode.nix;

    devShells.x86_64-linux.default = pkgs.mkShell {
      inherit (self.checks.x86_64-linux.pre-commit-check) shellHook;
    };

    checks.x86_64-linux.pre-commit-check = pre-commit-hooks.lib.x86_64-linux.run {
      src = ./.;
      hooks = {
        alejandra.enable = true;
        deadnix.enable = true;
        statix.enable = true;
      };
    };
  };
}
