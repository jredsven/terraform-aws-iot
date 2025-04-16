output "certificate_pem" {
  sensitive = true
  value     = aws_iot_certificate.cert.certificate_pem
}

output "certificate_private_key" {
  sensitive = true
  value     = aws_iot_certificate.cert.private_key
}

output "certificate_public_key" {
  sensitive = true
  value     = aws_iot_certificate.cert.public_key
}
