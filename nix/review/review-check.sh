if [ "${1:-}" = --help ]; then
  printf '%s\n' 'Format-check and validate every Terraform module without plans or applies.'
  exit 0
fi
# shellcheck source=/dev/null
source /workspace/nix/review/environment.sh
nixfmt --check flake.nix nix/review.nix
shellcheck -s bash nix/review/*.sh
mapfile -t roots < <(git ls-files '*.tf' | while IFS= read -r file; do dirname "$file"; done | sort -u)
for root in "${roots[@]}"; do
  printf '\n== %s ==\n' "$root"
  terraform -chdir="$root" fmt -check -diff -no-color
  terraform -chdir="$root" validate -no-color
  if [ -d "$root/tests" ]; then terraform -chdir="$root" test -no-color; fi
done
