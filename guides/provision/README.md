# Data Provision

To provision data on a provider connector, some steps need to be done:

## 0. Pre-requisites
You need to have deployed two EDC connectors (consumer and provider).

## 1. Create an Asset

### 1.1 Using IONOS S3

The following command creates an asset on the provider connector, using the IONOS S3 EDC extension to fetch the asset data as file store on a IONOS S3 bucket:

```bash
curl -X POST http://$PROVIDER_HOST:$PROVIDER_MANAGEMENT_PORT/management/v3/assets \
  -H 'content-type: application/json' \
  -H 'X-API-Key: $PROVIDER_API_KEY' \
  -d '{
    "@context": {
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
   },
   "@id":"asset-1",
   "dataAddress": {
     "type": "IonosS3",
     "storage": "s3-eu-central-1.ionoscloud.com",
     "bucketName": "$PROVIDER_BUCKET_NAME",
     "blobName": "$FILE_NAME",
     "keyName":"keyname-1"
    }
  }' -s | jq
```

Before executing the command, replace the following variables to its real values:
- $PROVIDER_HOST: the IP or DNS address to the provider connector;
- $PROVIDER_MANAGEMENT_PORT: port of the management API on the provider connector;
- $PROVIDER_API_KEY: default API key on the provider connector;
- $BUCKET_NAME: name of the IONOS S3 bucket used to store the provider asset file;
- $FILE_NAME: name of the provider asset file.

Example:
```bash
curl -X POST 'http://localhost:8182/management/v3/assets' \  
  -H 'Content-Type: application/json' \
  -H 'X-API-Key: password' \
  -d '{
    "@context": {
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@id": "asset-1",
    "dataAddress": {
      "type": "IonosS3",
      "storage": "s3-eu-central-1.ionoscloud.com",
      "bucketName": "provider-bucket",
      "blobName": "device1-data.csv",
      "keyName":"keyname-1"
   }
}' -s | jq
```

You will receive a response like bellow:
```json
{
  "@type": "IdResponse",
  "@id": "asset-1",
  "createdAt": 1716206385327,
  "@context": {
    "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
    "edc": "https://w3id.org/edc/v0.0.1/ns/",
    "odrl": "http://www.w3.org/ns/odrl/2/"
  }
}
```

## 2. Create a Policy

The following command creates a policy on the provider connector:

```bash
curl -X POST http://$PROVIDER_HOST:$PROVIDER_MANAGEMENT_PORT/management/v2/policydefinitions \
  -H 'content-type: application/json' \
  -H 'X-API-Key: $PROVIDER_API_KEY' \
  -d '{
    "@context":{
      "edc":"https://w3id.org/edc/v0.0.1/ns/",
      "odrl":"http://www.w3.org/ns/odrl/2/"
    },
    "@id":"policy-1",
    "policy": {
      "@type": "set",
      "odrl:permission":[],
      "odrl:prohibition":[],
      "odrl:obligation":[],
      "extensibleProperties": {
        "downloadable": "true"
      }
    }
  }' -s | jq
```

Before executing the command, replace the following variables to its real values:
- $PROVIDER_HOST: the IP or DNS address to the provider connector;
- $PROVIDER_MANAGEMENT_PORT: port of the management API on the provider connector;
- $PROVIDER_API_KEY: default API key on the provider connector.

Example:
```bash
curl -X POST 'http://localhost:8182/management/v2/policydefinitions' \  
  -H 'Content-Type: application/json' \
  -H 'X-API-Key: password' \
  -d '{
    "@context":{
      "edc":"https://w3id.org/edc/v0.0.1/ns/",
      "odrl":"http://www.w3.org/ns/odrl/2/"
    },
    "@id":"policy-1",
    "policy":{
      "@type":"set",
      "odrl:permission":[],
      "odrl:prohibition":[],
      "odrl:obligation":[],
      "extensibleProperties": {
        "downloadable": "true"
      }
    }
  }' -s | jq
```

You will receive a response like bellow:
```json
{
  "@type": "IdResponse",
  "@id": "policy-1",
  "createdAt": 1716206388035,
  "@context": {
    "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
    "edc": "https://w3id.org/edc/v0.0.1/ns/",
    "odrl": "http://www.w3.org/ns/odrl/2/"
  }
}
```

## 3. Create a Contract Definition

The following command creates a contract definition on the provider connector:

```bash
curl -X POST http://$PROVIDER_MANAGEMENT_PORT:$PROVIDER_MANAGEMENT_PORT/management/v2/contractdefinitions \
  -H 'content-type: application/json' \
  -H 'X-API-Key: $PROVIDER_API_KEY' \
  -d '
  {
    "@context":{
      "edc":"https://w3id.org/edc/v0.0.1/ns/"
    },
    "@id":"contract-1",
    "accessPolicyId":"policy-1",
    "contractPolicyId":"policy-1",
    "assetsSelector": [
      {
        "operandLeft": "https://w3id.org/edc/v0.0.1/ns/id",
        "operator": "=",
        "operandRight": "asset-1"
      }
    ]
  }' -s | jq
```

Before executing the command, replace the following variables to its real values:
- $PROVIDER_HOST: the IP or DNS address to the provider connector;
- $PROVIDER_MANAGEMENT_PORT: port of the management API on the provider connector;
- $PROVIDER_API_KEY: default API key on the provider connector.

Example:
```bash
curl -X POST 'http://localhost:8182/management/v2/contractdefinitions' \  
  -H 'Content-Type: application/json' \
  -H 'X-API-Key: password' \
  -d '{
   "@context":{
      "edc":"https://w3id.org/edc/v0.0.1/ns/"
   },
   "@id":"contract-1",
   "accessPolicyId":"policy-1",
   "contractPolicyId":"policy-1",
   "assetsSelector": [
      {
         "operandLeft": "https://w3id.org/edc/v0.0.1/ns/id",
         "operator": "=",
        "operandRight": "asset-1"
      }
   ]
  }' -s | jq
```

You will receive a response like bellow:
```json
{
  "@type": "IdResponse",
  "@id": "contract-1",
  "createdAt": 1716206391436,
  "@context": {
    "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
    "edc": "https://w3id.org/edc/v0.0.1/ns/",
    "odrl": "http://www.w3.org/ns/odrl/2/"
  }
}
```

[Next Chapter](../negotiation/README.md)