terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    kubernetes = {}
  }
}

variable "registry_url" {}
variable "registry_username" {}
variable "registry_password" {}

resource "docker_image" "consumer" {
  name = "consumer"
  build {
    context = "../../consumer"
    tag     = ["${var.registry_url}/edc-ionos-s3:consumer"]
  }
}

resource "docker_image" "provider" {
  name = "provider"
  build {
    context = "../../provider"
    tag     = ["${var.registry_url}/edc-ionos-s3:provider"]
  }
}

resource "null_resource" "docker_push" {
    provisioner "local-exec" {
    command = <<-EOT

    attempts=0
    max_attempts=120
    interval=30

    while true; do
      attempts=$((attempts+1))
      docker login -u ${var.registry_username} -p ${var.registry_password} ${var.registry_url} && \
      docker push ${var.registry_url}/edc-ionos-s3:consumer && \
      docker push ${var.registry_url}/edc-ionos-s3:provider && \
      break

      if [ $attempts -eq $max_attempts ]; then
        echo "Maximum attempts reached. Exiting..."
        exit 1
      fi

      echo "Attempt $attempts failed. Retrying in $interval seconds..."
      sleep $interval
    done
    EOT
    }

    depends_on = [
      docker_image.consumer,
      docker_image.provider
    ]
}