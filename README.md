# trade-tariff-terraform-modules

This repository contains terraform modules that support the UK Trade Tariff Service

## Rationale

These modules were originally contained within the _trade-tariff-platform_ repository however in order to pin them we've moved them to their own repository.
As we only currently have only a few modules, putting them into a single repository felt like an easier option rather than making them seperate and pinning them seperately although if we get more modules we should split them out.

## Requirements

- Terraform

## Usage

### Cloudfront

```hcl
module "example_cloudfront" {
}
```

### ACM

```hcl
module "example_acm" {

}


Test if lifecucle config applied
