output "configuration" {
  description = "Base64 encoded Talos configuration"
  value       = base64encode(local.configuration)
}
