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
      self,
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

        reviewTestMode = pkgs.writeShellApplication {
          name = "review-check-test-mode";
          runtimeInputs = [ (pkgs.python3.withPackages (ps: [ ps.python-hcl2 ])) ];
          text = ''
            python3 - "$@" <<'PY'
            import json
            import sys
            from pathlib import Path
            import hcl2

            root = Path(sys.argv[1])
            paths = sorted(root.glob("*.tftest.*")) + sorted((root / "tests").rglob("*.tftest.*"))
            count = 0
            for path in paths:
                with path.open() as stream:
                    if path.suffix == ".hcl":
                        data = hcl2.load(stream)
                    elif path.suffix == ".json":
                        data = json.load(stream)
                    else:
                        raise SystemExit(f"Unsupported Terraform test file: {path}")
                groups = data.get("run", [])
                if isinstance(groups, dict):
                    groups = [groups]
                for group in groups:
                    for name, run in group.items():
                        if not isinstance(run, dict) or run.get("command") not in ("plan", "''${plan}"):
                            raise SystemExit(f"Terraform test requires explicit command = plan: {path}:{name}")
                        count += 1
            if not count:
                raise SystemExit(f"No Terraform test runs found: {root}")
            print(f"Checked {count} plan-only Terraform test runs.")
            PY
          '';
        };

        reviewEnvironment = ''
          if [ "''${REVIEW_SANDBOX:-}" != 1 ] || [ "$PWD" != /workspace ]; then
            echo 'Run review commands inside a disposable review sandbox.' >&2
            exit 64
          fi
          export TMPDIR=/workspace/.review/tmp
          export PRE_COMMIT_HOME=/workspace/.review/pre-commit
          export TF_CLI_CONFIG_FILE=/workspace/.review/terraform.rc
          for name in "''${!AWS_@}" "''${!TF_CLI_ARGS@}"; do
            if [ -n "$name" ]; then unset "$name"; fi
          done
          export TF_IN_AUTOMATION=1 TF_INPUT=0 CHECKPOINT_DISABLE=1 AWS_EC2_METADATA_DISABLED=true AWS_REGION=eu-west-2
          export AWS_CONFIG_FILE=/dev/null AWS_SHARED_CREDENTIALS_FILE=/dev/null
          unset TF_PLUGIN_CACHE_DIR
          files="$(git ls-files '*.tf')"
          if [ -z "$files" ]; then
            echo 'No tracked Terraform modules found.' >&2
            exit 1
          fi
          mapfile -t roots < <(printf '%s\n' "$files" | while IFS= read -r file; do dirname "$file"; done | sort -u)
          mkdir -p "$TMPDIR"
        '';

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
        devShells.review = self.devShells.${system}.default.overrideAttrs (old: {
          shellHook = "";
          nativeBuildInputs = [
            pkgs.gitMinimal
            preCommitCheck.config.package
            reviewTestMode
            (pkgs.writeShellApplication {
              name = "review-bootstrap";
              text = reviewEnvironment + ''
                test -d /deps/terraform-inputs/providers
                printf 'disable_checkpoint = true\nprovider_installation {\n filesystem_mirror {\n path = "/deps/terraform-inputs/providers"\n include = ["registry.terraform.io/*/*"]\n }\n}\n' > "$TF_CLI_CONFIG_FILE"
                for root in "''${roots[@]}"; do
                  mkdir -p "$root/.terraform/modules"
                  if [ -f "/deps/terraform-inputs/roots/$root/modules.json" ]; then cp "/deps/terraform-inputs/roots/$root/modules.json" "$root/.terraform/modules/modules.json"; fi
                  if [ ! -f "$root/.terraform.lock.hcl" ]; then cp "/deps/terraform-inputs/roots/$root/lock.hcl" "$root/.terraform.lock.hcl"; fi
                  terraform -chdir="$root" init -backend=false -input=false -lockfile=readonly -no-color
                done
              '';
            })
            (pkgs.writeShellApplication {
              name = "review-check";
              text = reviewEnvironment + ''
                pre-commit run --all-files --config ${preCommitCheck.config.configFile}
                for root in "''${roots[@]}"; do
                  terraform -chdir="$root" validate -no-color
                  if [ -d "$root/tests" ]; then
                    review-check-test-mode "$root"
                    terraform -chdir="$root" test -no-color
                  fi
                done
              '';
            })
          ]
          ++ (old.nativeBuildInputs or [ ]);
          TZDIR = "${pkgs.tzdata.outPath}/share/zoneinfo";
          SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        });

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
