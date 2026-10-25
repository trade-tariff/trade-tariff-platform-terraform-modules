# Isolated review shell

Select `devShells.review` in the sandbox runner. The default developer shell is unchanged, and the review shell does not run a shell hook.

Run `review-bootstrap`, then `review-check`. The runner must use `/workspace` and set `REVIEW_SANDBOX=1`; both commands refuse to change a host checkout. Use `--help` to inspect the commands without setup.

Supply the selected module and provider inputs read-only at `/deps/terraform-inputs`. Its `providers` directory is a filesystem mirror. Its `roots/<module-path>` directories contain `lock.hcl` and, where needed, `modules.json`. Module manifest paths must resolve to the supplied sources inside the sandbox.

Every Terraform root is initialized with its backend disabled, then format-checked and validated. Tests run where present. The commands do not request AWS credentials, read remote state, plan or apply infrastructure. Keep results and workspace changes in local artifacts before cleanup.
