# Separate example

This example shows how to use deploy ECR module only once per region and then use `kompass_compute` per cluster.

The `1-ecr` module is used to create an ECR repository in the specified region,
and the `2-kompass` module is used to deploy the Kompass compute resources in the specified cluster.

Note: It is recommended to deploy `ecr` module only once per region.
ECR pull-through cache rules are regional resources, and creating them multiple times
is not necessary and may lead to conflicts.
