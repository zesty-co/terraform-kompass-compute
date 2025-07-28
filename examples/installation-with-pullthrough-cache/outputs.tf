output "helm_values_yaml" {
  description = "Merged helm_values_yaml outputs from the kompass_compute and ecr submodules"
  value       = "${module.kompass_compute.helm_values_yaml}\n${module.ecr.helm_values_yaml}"
}