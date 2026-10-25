if [ "${1:-}" = --help ]; then
  printf '%s\n' 'Initialize every Terraform module without an AWS backend.' 'Provide a verified module/provider cache at /deps/terraform-inputs.'
  exit 0
fi
# shellcheck source=/dev/null
source /workspace/nix/review/environment.sh
test -d /deps/terraform-inputs/providers
printf 'disable_checkpoint = true\nprovider_installation {\n filesystem_mirror {\n path = "/deps/terraform-inputs/providers"\n include = ["registry.terraform.io/*/*"]\n }\n}\n' > "$TF_CLI_CONFIG_FILE"
mapfile -t roots < <(git ls-files '*.tf' | while IFS= read -r file; do dirname "$file"; done | sort -u)
for root in "${roots[@]}"; do
  mkdir -p "$root/.terraform/modules"
  if [ -f "/deps/terraform-inputs/roots/$root/modules.json" ]; then cp "/deps/terraform-inputs/roots/$root/modules.json" "$root/.terraform/modules/modules.json"; fi
  if [ ! -f "$root/.terraform.lock.hcl" ]; then cp "/deps/terraform-inputs/roots/$root/lock.hcl" "$root/.terraform.lock.hcl"; fi
  terraform -chdir="$root" init -backend=false -input=false -lockfile=readonly -no-color
done
