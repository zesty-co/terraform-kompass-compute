output "helm_values_yaml" {
  description = "Merged helm_values_yaml outputs from the kompass_compute and ecr submodules"
  value       = join("\n", [module.kompass_compute.helm_values_yaml, module.ecr.helm_values_yaml])
}