output "Endpoint" {
  value = azapi_resource.amr_cluster.output.properties.hostName
}

output "Primary_Key" {
  value = data.azapi_resource_action.listKeys.output.primaryKey
}

output "Secondary_Key" {
  value = data.azapi_resource_action.listKeys.output.secondaryKey
}
