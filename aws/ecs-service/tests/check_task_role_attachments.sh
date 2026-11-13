#!/usr/bin/env bash
# Regression check for the task role permissions.
#
# The assertions in task_role_iam.tftest.hcl can only reference resources by
# address, so they cannot see a new or restored attachment such as the removed
# AmazonECS_FullAccess one. This script reads the plan JSON of every run in that
# file. Only aws_iam_role_policy_attachment.task_role_additional_policies may
# attach a policy to the task role. The tftest assertions check which policies
# those attachments use.
set -euo pipefail

cd "$(dirname "$0")/.."

TEST_FILE="tests/task_role_iam.tftest.hcl"
ALLOWED_PREFIX="aws_iam_role_policy_attachment.task_role_additional_policies["

output="$(mktemp)"
trap 'rm -f "$output"' EXIT

terraform test -no-color -json -verbose -filter="$TEST_FILE" >"$output"

jq -e -s '.[] | select(.type == "test_summary") | .test_summary.status == "pass"' "$output" >/dev/null || {
  echo "terraform test did not pass for $TEST_FILE" >&2
  exit 1
}

result="$(jq -s -c --arg allowed "$ALLOWED_PREFIX" '
  [
    .[]
    | select(.type == "test_plan")
    | ."@testrun" as $run
    | [.test_plan.resource_changes[] | select(.change.actions | index("delete") | not)] as $changes
    | ([$changes[] | select(.address == "aws_iam_role.task_role") | .change.after.name] | first) as $role
    | {
        run: $run,
        role: $role,
        attachments: [
          $changes[]
          | .address as $address
          | .change.after as $after
          | (
              # Policy attachments to the task role, of any resource type.
              (select($role != null and (($after.role? == $role) or (($after.roles? // []) | index($role))))
                | ([$after.policy_arn?] + ($after.policy_arns? // []))[]
                | select(. != null)),
              # Managed policies set directly on the task role.
              (select(.address == "aws_iam_role.task_role")
                | ($after.managed_policy_arns? // [])[])
            )
          | {address: $address, arn: .}
        ]
      }
  ]
  | {
      plans: length,
      missing_role: [.[] | select(.role == null) | .run],
      allowed_seen: [.[] | .attachments[] | select(.address | startswith($allowed))] | length,
      violations: [
        .[] | .run as $run | .role as $role
        | .attachments[] | select(.address | startswith($allowed) | not)
        | "\($run): \(.address) attaches \(.arn) to \($role)"
      ]
    }
' "$output")"

fail() {
  echo "$1" >&2
  exit 1
}

[ "$(jq '.plans' <<<"$result")" -gt 0 ] || fail "no plans found in terraform test output"

missing="$(jq -r '.missing_role[]' <<<"$result")"
[ -z "$missing" ] || fail "aws_iam_role.task_role name not found in plan for runs: $missing"

# Positive control: if the plan JSON shape changes so that attachments are not
# found, this check fails instead of passing with no violations.
[ "$(jq '.allowed_seen' <<<"$result")" -gt 0 ] ||
  fail "no task_role_additional_policies attachment found in any plan; the plan JSON shape may have changed"

violations="$(jq -r '.violations[]' <<<"$result")"
[ -z "$violations" ] || fail "task role has unexpected policy attachments:
$violations"

echo "task role attachments OK in $(jq '.plans' <<<"$result") plans"
