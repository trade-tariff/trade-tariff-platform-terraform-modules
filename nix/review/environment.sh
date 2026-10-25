# shellcheck shell=bash
if [ "${REVIEW_SANDBOX:-}" != 1 ] || [ "$PWD" != /workspace ]; then
  printf '%s\n' 'Run review commands inside a disposable review sandbox.' >&2
  exit 64
fi
export TMPDIR=/workspace/.review/tmp
mkdir -p "$TMPDIR"
export TF_CLI_CONFIG_FILE=/workspace/.review/terraform.rc
export TF_IN_AUTOMATION=1 TF_INPUT=0 CHECKPOINT_DISABLE=1 AWS_EC2_METADATA_DISABLED=true AWS_REGION=eu-west-2
unset TF_PLUGIN_CACHE_DIR
