with import <nixpkgs> {};

let
  tf = terraform.withPlugins(p: with p; [
  ]);

in
mkShell {
  buildInputs = [
    pre-commit
    terraform-docs
    terraform-ls
    tf
    tflint
  ];
}
