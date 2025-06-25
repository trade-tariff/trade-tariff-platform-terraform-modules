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
    nixpkgs-terraform.url = "github:stackbuilders/nixpkgs-terraform";
  };

  outputs = { self, nixpkgs, flake-utils, nixpkgs-terraform }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        terraform = nixpkgs-terraform.packages.${system}."1.12";
        pkgs = import nixpkgs { inherit system; };

        lint = pkgs.writeScriptBin "lint" ''
          ${pkgs.pre-commit}/bin/pre-commit run -a
        '';

        clean = pkgs.writeScriptBin "clean" ''
          find . -type d -name ".terraform" | xargs -- rm -rf
          find . -type f -name ".terraform.lock.hcl" -delete
        '';

        init = pkgs.writeScriptBin "init" ''
          cd aws/ecs-service && terraform init -input=false -no-color -backend=false && cd ../..
        '';

        update-providers = pkgs.writeScriptBin "update-providers" ''clean && init'';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            terraform        # For terraform_fmt, terraform_validate
            terragrunt       # For terragrunt-hclfmt
            tflint           # For terraform_tflint
            terraform-docs   # For terraform_docs
            pre-commit       # For running hooks
            trufflehog       # For trufflehog secret scanning
            lint             # Custom lint script
            clean            # Custom clean script to remove Terraform state and lock files
            init             # Custom init script to get all the modules for validation
            update-providers # Custom script to update all the providers
          ];

          shellHook = ''
            export AWS_REGION="eu-west-2"
            export AWS_ACCESS_KEY_ID="your-key"
            export AWS_SECRET_ACCESS_KEY="your-secret"
          '';
        };
      });
}
