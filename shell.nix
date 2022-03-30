with import <nixpkgs> {};

let
  tf = terraform.withPlugins(p: with p; [
    aws
  ]);

  circleci-cli = pkgs.circleci-cli.overrideAttrs (attrs: rec {
    version = "0.1.16947";
    owner = "CircleCI-Public";
    pname = "circleci-cli";
    src = pkgs.fetchFromGitHub {
      inherit owner;
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-RGkC1XhrssrX4IBh1OrzEowvbPPUK7jXZxxa+FEV/WE=";
    };
  });

in
mkShell {
  buildInputs = [
    circleci-cli
    pre-commit
    terraform-docs
    terraform-ls
    tf
    tflint
    shellcheck
  ];

  shellHook = ''
    # This won't expand unless you're interactive.
    alias circleci="${circleci-cli}/bin/circleci-cli"
  '';
}
