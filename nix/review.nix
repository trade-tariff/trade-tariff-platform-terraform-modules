{ pkgs, baseShell }:
let
  command =
    name:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [
        pkgs.bash
        pkgs.coreutils
        pkgs.git
      ];
      text = builtins.readFile (./review + "/${name}.sh");
    };
in
baseShell.overrideAttrs (old: {
  name = "trade-tariff-modules-review";
  shellHook = "";
  nativeBuildInputs = [
    (command "review-bootstrap")
    (command "review-check")
    pkgs.nixfmt
    pkgs.shellcheck
  ]
  ++ (old.nativeBuildInputs or [ ]);
  TZDIR = "${pkgs.tzdata}/share/zoneinfo";
  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
})
