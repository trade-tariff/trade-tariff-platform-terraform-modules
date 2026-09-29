# Trade Tariff Terraform modules

This repository contains reusable Terraform modules for the Online Trade Tariff
platform. The [ECS service module](aws/ecs-service/README.md) defines application
services and their supporting resources. Consumers select a module version through
a Git reference rather than copying its source.

Environment-specific infrastructure belongs in
[trade-tariff-platform-aws-terraform](https://github.com/trade-tariff/trade-tariff-platform-aws-terraform).
This repository is not a root configuration to apply to an AWS account.

## Use a module

Read the module's README for requirements, inputs and outputs. Use a reviewed
commit or release reference in the consumer's source URL. Updating a reference
can change resources in the consuming project; review that project's plan
before applying it.

## Check changes

Use a Terraform version compatible with the module's requirements. From the
repository root:

```sh
terraform fmt -check -recursive
cd aws/ecs-service
terraform init -backend=false
terraform validate
```

Initialisation downloads providers and modules. These checks do not apply AWS
resources. Validate the affected consumers separately before releasing a module
change. See [CI configuration](.github/workflows/ci.yml) for the automated checks.

## Contribute

Read [CONTRIBUTING.md](CONTRIBUTING.md) for the fork workflow, checks and private
security reporting. Preserve input and output compatibility unless a breaking
change is explicitly agreed with consumers.

## Licence

The repository uses the [MIT licence](LICENSE), including the existing
ENGINE Transformation copyright notice. Dependencies retain their own licences.
