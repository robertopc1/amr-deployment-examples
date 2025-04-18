output "redis_location1_name" {
  value = azapi_resource.amr_cluster.name
}

output "redis_location1_id" {
  value = azapi_resource.amr_cluster.id
}

output "redis_location1_host_name" {
  value = azapi_resource.amr_cluster.output["properties"]["hostName"]
}