{
  nixConfig = {
    extra-substituters = [
      "https://nixpkgs-terraform.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-terraform.url = "github:stackbuilders/nixpkgs-terraform";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      pre-commit-hooks,
      nixpkgs-terraform,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        terraform = nixpkgs-terraform.packages.${system}."1.12";
        pkgs = import nixpkgs { inherit system; };

        lint = pkgs.writeShellScriptBin "lint" ''
          pre-commit run --all-files
        '';

        clean = pkgs.writeShellScriptBin "clean" ''
          find . -type d -name ".terraform" | xargs -- rm -rf
          find . -type f -name ".terraform.lock.hcl" -delete
        '';

        init = pkgs.writeShellScriptBin "init" ''
          cd aws/ecs-service && terraform init -input=false -no-color -backend=false && cd ../..
        '';

        update-providers = pkgs.writeShellScriptBin "update-providers" "clean && init";

        preCommitCheck = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          configPath = ".pre-commit-config-nix.yaml";
          default_stages = [ "pre-commit" ];
          hooks = {
            actionlint = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-added-large-files = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-case-conflicts = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-merge-conflicts = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-yaml = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            deadnix = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            detect-private-keys = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            end-of-file-fixer = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            nixfmt-rfc-style = {
              package = pre-commit-hooks.inputs.nixpkgs.legacyPackages.${system}.nixfmt;
              enable = true;
              stages = [ "pre-commit" ];
            };
            statix = {
              enable = true;
              settings.ignore = [ "{.direnv,.nix,.worktrees}/**" ];
              stages = [ "pre-commit" ];
            };
            terraform-format = {
              enable = true;
              package = terraform;
              stages = [ "pre-commit" ];
            };
            trim-trailing-whitespace = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            trufflehog = {
              enable = true;
              stages = [ "pre-commit" ];
            };
          };
        };

        preCommit = pkgs.writeShellScriptBin "pre-commit" ''
          set -euo pipefail

          has_config=false
          for arg in "$@"; do
            case "$arg" in
              -c|--config|--config=*)
                has_config=true
                ;;
            esac
          done

          if [ "$has_config" = true ]; then
            exec ${preCommitCheck.config.package}/bin/pre-commit "$@"
          fi

          if [ "''${1:-}" = "run" ]; then
            shift
            exec ${preCommitCheck.config.package}/bin/pre-commit run --config .pre-commit-config-nix.yaml "$@"
          fi

          exec ${preCommitCheck.config.package}/bin/pre-commit "$@"
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs =
            preCommitCheck.enabledPackages
            ++ (with pkgs; [
              terraform # For terraform_fmt, terraform_validate
              terragrunt # For terragrunt-hclfmt
              tflint # For terraform_tflint
              terraform-docs # For terraform_docs
              trufflehog # For trufflehog secret scanning
              lint # Custom lint script
              clean # Custom clean script to remove Terraform state and lock files
              init # Custom init script to get all the modules for validation
              update-providers # Custom script to update all the providers
            ]);

          shellHook = ''
            export AWS_REGION="eu-west-2"
            export AWS_ACCESS_KEY_ID="your-key"
            export AWS_SECRET_ACCESS_KEY="your-secret"
            ${preCommitCheck.shellHook}
            export PATH=${preCommit}/bin:$PATH
          '';
        };
      }
    );
}
