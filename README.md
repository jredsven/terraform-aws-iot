# terraform-aws-iot

## Example usage

```hcl
module "iot" {
  source = "git@github.com:jredsven/terraform-aws-iot.git"
}

output "certificate_pem" {
  sensitive = true
  value     = module.iot.certificate_pem
}

output "certificate_private_key" {
  sensitive = true
  value     = module.iot.certificate_private_key
}

output "certificate_public_key" {
  sensitive = true
  value     = module.iot.certificate_public_key
}

output "iot_endpoint" {
  value = module.iot.iot_endpoint
}

```

## Certificate as PEM

```
terraform output -json | jq -r '.certificate_pem.value'
```

## Certificate private key

```
terraform output -json | jq -r '.certificate_private_key.value'
```

## Certificate public key

```
terraform output -json | jq -r '.certificate_public_key.value'
```
