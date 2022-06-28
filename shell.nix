with import <nixpkgs> {};

mkShell {
  buildInputs = [
    pre-commit
    terraform-docs
    terraform-ls
    tflint
  ];

}
