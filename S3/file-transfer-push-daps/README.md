# File transfer using push method on Kubernetes

This example shows how to exchange a data file between two EDC's. It is based on a sample of the official EDC respository.

The connectors are deployed on Kubernetes cluster and use IDS DAPS as Identity Provider.

You can execute this example by using only one IONOS account (more for development purpose) or by using two IONOS accounts (similar to production purpose).

## Requirements

You will need the following:
- IONOS account;
- Java Development Kit (JDK) 17 or higher;
- Docker;
- GIT;
- Linux shell or PowerShell;
- Linux JQ tool;
- [Kubernetes cluster](https://kubernetes.io/docs/setup/) - **Note:** You can use the terraform script in [ionos-kubernetes-cluster](https://github.com/Digital-Ecosystems/ionos-kubernetes-cluster) repository to deploy a kubernetes cluster on IONOS DCD.
- [DAPS server](https://github.com/Digital-Ecosystems/ionos-daps) - **Note:** You can follow the instructions in the [ionos-daps](https://github.com/Digital-Ecosystems/ionos-daps) repository to deploy a DAPS server on IONOS DCD.
- 3 public IPs
- DNS server and domain name


## Deployment

### Configuration
In order to configure this sample, please follow this steps:
(We will use the [DCD](https://dcd.ionos.com))
1) Create a Kubernetes cluster and deploy DAPS service. Follow the instructions from the [ionos-daps](https://github.com/Digital-Ecosystems/ionos-daps).
2) Create a Repository on a Container Registry service and get a user and password to access it.
3) Create a S3 Key Management: access the `Storage/Object Storage/S3 Key Management` option and generate a Key. Keep the key and the secret;
4) Create the required buckets: access the `Storage/Object Storage/S3 Web Console` option and create two buckets: one for the provider and another for the consumer;
5) Upload a file named `device1-data.csv` into the provider bucket. You can use the `s3/file-transfer-push-daps/device1-data.csv`;
6) Create a token that the consumer will use to do the provisioning. Take a look at this [documentation](https://github.com/ionos-cloud/edc-ionos-s3/blob/main/ionos_token.md);

Note: by design, S3 technology allows only unique names for the buckets. You may find an error saying that the bucket name already exists.

## Usage

Create `S3/file-transfer-push-daps/terraform/.env` file from the `s3/file-transfer-push-daps/terraform/.env-example` file.

```bash
cp terraform/.env-example terraform/.env
```

Open `S3/file-transfer-push-daps/terraform/.env` and set all the variables.

```bash
# Navigate to the terraform folder
cd terraform

# Deploy the services
./deploy-services.sh
```

```bash
# Set the provider and consumer addresses
export PROVIDER_ADDRESS=$(kubectl get svc -n edc-ionos-s3-provider edc-ionos-s3-provider -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export CONSUMER_ADDRESS=$(kubectl get svc -n edc-ionos-s3-consumer edc-ionos-s3-consumer -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

## Transfer file

Follow the instructions of the [push transfer guide](../../guides/transfer/push/README.md) to perform a data transfer between the two connectors.

## Troubleshooting
Get the logs from the connector pods

Provider
```bash
kubectl logs -n edc-ionos-s3-consumer deploy/edc-ionos-s3-consumer -f
```

Consumer
```bash
kubectl logs -n edc-ionos-s3-provider deploy/edc-ionos-s3-provider -f
```

## Cleanup

```bash
# Navigate to the terraform folder
cd terraform

# Destroy the services
./deploy-services.sh destroy
```

## References
[deploy-services.sh documentation](./terraform/deploy-services.md)