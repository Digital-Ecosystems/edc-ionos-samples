provider "helm" {
  kubernetes {
    config_path = "${var.kubeconfig}"
  }
}

variable "kubeconfig" {
  type = string
}

variable "daps_url" {}
variable "registry_url" {}
variable "registry_username" {}
variable "registry_password" {}

# Consumer
variable "namespace_consumer" {
  default = "edc-ionos-s3-consumer"
}
variable "consumer_dsp_webhook_address" {
  default = "http://localhost:8282/protocol"
}
variable "consumer_edc_keystore_password" {
  default = "consumer"
}
variable "consumer_image_tag" {
  default = "consumer"
}

# Provider
variable "namespace_provider" {
  default = "edc-ionos-s3-provider"
}
variable "provider_dsp_webhook_address" {
  default = "http://localhost:8282/protocol"
}
variable "provider_edc_keystore_password" {
  default = "provider"
}
variable "provider_image_tag" {
  default = "provider"
}

variable "s3_access_key" {}
variable "s3_secret_key" {}
variable "s3_endpoint" {}
variable "ionos_token" {}

locals {
  root_token = "${jsondecode(file("../vault-init/vault-keys.json")).root_token}"

  consumer_edc_oauth_clientId = "${yamldecode(file("../create-daps-clients/connectors/consumer/config/clients.yml"))[0].client_id}"
  consumer_edc_keystore = "${filebase64("../create-daps-clients/connectors/consumer/keystore.p12")}"

  provider_edc_oauth_clientId = "${yamldecode(file("../create-daps-clients/connectors/provider/config/clients.yml"))[0].client_id}"
  provider_edc_keystore = "${filebase64("../create-daps-clients/connectors/provider/keystore.p12")}"
}

resource "helm_release" "edc-ionos-s3-consumer" {
  name       = "edc-ionos-s3-consumer"

  repository = "../../helm"
  chart      = "edc-ionos-s3"

  namespace = var.namespace_consumer
  create_namespace = true

  values = [
    "${file("../../helm/edc-ionos-s3/values.yaml")}",
  ]

  set {
    name  = "edc.vault.hashicorp.url"
    value = "http://vault.edc-ionos-s3-vault.svc.cluster.local:8200"
  }

  set {
    name  = "edc.vault.hashicorp.token"
    value = local.root_token
  }

  set {
    name  = "edc.ionos.endpoint"
    value = var.s3_endpoint
  }

  set {
    name  = "edc.ionos.token"
    value = var.ionos_token
  }

  set {
    name  = "edc.dsp.callback.address"
    value = var.consumer_dsp_webhook_address
  }

  set {
    name  = "edc.keystore"
    value = local.consumer_edc_keystore
  }

  set {
    name  = "edc.keystorePassword"
    value = var.consumer_edc_keystore_password
  }

  set {
    name  = "edc.oauth.tokenUrl"
    value = "${var.daps_url}/token"
  }

  set {
    name  = "edc.oauth.clientId"
    value = local.consumer_edc_oauth_clientId
  }

  set {
    name  = "edc.oauth.providerJwksUrl"
    value = "${var.daps_url}/jwks.json"
  }

  set {
    name  = "image.repository"
    value = "${var.registry_url}/edc-ionos-s3"
  }

  set {
    name  = "image.tag"
    value = var.consumer_image_tag
  }

  set {
    name  = "imagePullSecret.username"
    value = "${var.registry_username}"
  }

  set {
    name  = "imagePullSecret.password"
    value = "${var.registry_password}"
  }

  set {
    name  = "imagePullSecret.server"
    value = "${var.registry_url}"
  }
}

resource "helm_release" "edc-ionos-s3-provider" {
  name       = "edc-ionos-s3-provider"

  repository = "../../helm"
  chart      = "edc-ionos-s3"

  namespace = var.namespace_provider
  create_namespace = true

  values = [
    "${file("../../helm/edc-ionos-s3/values.yaml")}",
  ]

  set {
    name  = "edc.vault.hashicorp.url"
    value = "http://vault.edc-ionos-s3-vault.svc.cluster.local:8200"
  }

  set {
    name  = "edc.vault.hashicorp.token"
    value = local.root_token
  }

  set {
    name  = "edc.ionos.accessKey"
    value = var.s3_access_key
  }

  set {
    name  = "edc.ionos.secretKey"
    value = var.s3_secret_key
  }

  set {
    name  = "edc.ionos.endpoint"
    value = var.s3_endpoint
  }

  set {
    name  = "edc.dsp.callback.address"
    value = var.provider_dsp_webhook_address
  }

  set {
    name  = "edc.keystore"
    value = local.provider_edc_keystore
  }

  set {
    name  = "edc.keystorePassword"
    value = var.provider_edc_keystore_password
  }

  set {
    name  = "edc.oauth.tokenUrl"
    value = "${var.daps_url}/token"
  }

  set {
    name  = "edc.oauth.clientId"
    value = local.provider_edc_oauth_clientId
  }

  set {
    name  = "edc.oauth.providerJwksUrl"
    value = "${var.daps_url}/jwks.json"
  }

  set {
    name  = "image.repository"
    value = "${var.registry_url}/edc-ionos-s3"
  }

  set {
    name  = "image.tag"
    value = var.provider_image_tag
  }

  set {
    name  = "imagePullSecret.username"
    value = "${var.registry_username}"
  }

  set {
    name  = "imagePullSecret.password"
    value = "${var.registry_password}"
  }

  set {
    name  = "imagePullSecret.server"
    value = "${var.registry_url}"
  }

}
