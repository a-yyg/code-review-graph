{
  description = "Persistent incremental knowledge graph for token-efficient, context-aware code reviews";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      python3 = pkgs.python3.override {
        packageOverrides = pyself: pysuper: {
          aioboto3 = pysuper.aioboto3.overridePythonAttrs (old: {
            doCheck = false;
          });
        };
      };
    in
    {
      packages.${system} = {
        code-review-graph = python3.pkgs.buildPythonApplication {
          pname = "code-review-graph";
          version = "2.3.2";
          pyproject = true;

          src = ./.;

          build-system = [ python3.pkgs.hatchling ];

          dependencies = with python3.pkgs; [
            mcp
            fastmcp
            tree-sitter
            tree-sitter-language-pack
            networkx
            watchdog
            tomli
          ];

          pythonRelaxDeps = [
            "fastmcp"
            "tree-sitter-language-pack"
            "watchdog"
          ];
          nativeBuildInputs = [ python3.pkgs.pythonRelaxDepsHook ];
        };
        default = self.packages.${system}.code-review-graph;
      };

      apps.${system} = {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/code-review-graph";
        };
      };
    };
}
