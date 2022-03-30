with import <nixpkgs> {};

let
  tf = terraform.withPlugins(p: with p; [
  ]);

in
mkShell {
  buildInputs = [
    tf
    terraform-docs
    terraform-ls
    pre-commit
    tflint
  ];
}
