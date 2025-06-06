# Simple deployment of 2 EDC's

This example shows how to do a simple deployment of two EDC's using a Terraform script and also how to do a file exchange between a Provider and a Consumer.

## Deployment

You will create 2 `folders` called `Consumer` and `Provider`, for each of them do the checkout of this repository and follow this [readme](https://github.com/ionos-cloud/edc-ionos-s3/tree/main/deployment/README.md).

**Don't forget to create unique parameters for each connector.**

Example:  
`Consumer`
```bash
export TF_VAR_namespace="edc-consumer"
export TF_VAR_vaultname="vaultconsumer"
```
`Provider`
```bash
export TF_VAR_namespace="edc-provider"
export TF_VAR_vaultname="vaultprovider"
```

## Usage
We will transfer the `device1-data.csv` file of this directory. 

### Configure the external IPs
First, we need to open a `shell console` to execute the following instructions.

```bash
# external IPs
CONSUMER_IP=<IP ADDRESS OF THE CONSUMER CONNECTOR>
PROVIDER_IP=<IP ADDRESS OF THE PROVIDER CONNECTOR>

# buckets
export CONSUMER_BUCKET=<CONSUMER BUCKET NAME>
export PROVIDER_BUCKET=<PROVIDER BUCKET NAME>

# healthcheck
curl http://$PROVIDER_IP:8181/api/check/health
curl http://$CONSUMER_IP:8181/api/check/health
```

### File exchange flow

1) Asset creation for the consumer
```console
curl --header 'X-API-Key: password' \
-d '{
       "@context": {
         "edc": "https://w3id.org/edc/v0.0.1/ns/"
       },
        "@id": "assetId",
        "properties": {
          "name": "product description",
          "contenttype": "application/json"
        },
       "dataAddress": {
         
          "type": "AzureStorage",
          "bucketName": "'$PROVIDER_BUCKET'",
          "container": "'$PROVIDER_BUCKET'",
          "blobName": "device1-data.csv",
          "storage": "s3-eu-central-1.ionoscloud.com",
          "keyName": "device1-data.csv",
          "type": "IonosS3"
         
       }
     }' -H 'content-type: application/json' http://$PROVIDER_IP:8182/management/v3/assets \
         -s | jq
```

2) Policy creation
```console
curl -d '{
           "@context": {
                "edc": "https://w3id.org/edc/v0.0.1/ns/",
                "odrl": "http://www.w3.org/ns/odrl/2/"
           },
           "@id": "aPolicy",
           "policy": {
             "@type": "set",
             "odrl:permission": [],
             "odrl:prohibition": [],
             "odrl:obligation": []
           }
         }' -H 'X-API-Key: password' \
        -H 'content-type: application/json' http://$PROVIDER_IP:8182/management/v3/policydefinitions
```

3) Contract creation
```console
curl -d '{
           "@context": {
             "edc": "https://w3id.org/edc/v0.0.1/ns/"
           },
           "@id": "1",
           "accessPolicyId": "aPolicy",
           "contractPolicyId": "aPolicy",
           "assetsSelector": []
         }' -H 'X-API-Key: password' \
        -H 'content-type: application/json' http://$PROVIDER_IP:8182/management/v3/contractdefinitions
```

4) Fetching the catalog
```console
curl -X POST "http://$CONSUMER_IP:8182/management/v3/catalog/request" \
--header 'X-API-Key: password' \
--header 'Content-Type: application/json' \
-d @- <<-EOF
{
      "@context": {
        "edc": "https://w3id.org/edc/v0.0.1/ns/"
      },
      "providerUrl": "http://PROVIDER_IP:8282/protocol",
      "protocol": "dataspace-protocol-http"
    }
EOF
```

5) Contract negotiation
```console

    export JSON_PAYLOAD=$(curl --location --request POST 'http://$CONSUMER_ADDRESS:8182/management/v3/contractnegotiations' \
    --header 'X-API-Key: password' \
    --header 'Content-Type: application/json' \
    --data-raw '{
      "@context": {
        "edc": "https://w3id.org/edc/v0.0.1/ns/",
        "odrl": "http://www.w3.org/ns/odrl/2/"
      },
     
      "counterPartyAddress": "http://$PROVIDER_ADDRESS:8282/protocol",
       "protocol": "dataspace-protocol-http",
      "policy": {
              "@context": "http://www.w3.org/ns/odrl.jsonld",
              "@id": "$OFFER_POLICY",
              "@type": "Offer",
              "assigner": "provider",
              "target": "asset-154"
        }
     }' -s | jq -r '.["@id"]')
```
```console    
ID=$(curl -s --header 'X-API-Key: password' -X POST -H 'content-type: application/json'  "http://$CONSUMER_IP:8182/management/v2/contractnegotiations/$CONTRACT_NEGOTIATION_ID" | jq -r '.contractAgreementId')
echo $ID
```

6) Contract agreement
```console
CONTRACT_AGREEMENT_ID=$(curl -X GET "http://$CONSUMER_IP:8182/management/v3/data/contractnegotiations/$ID" \
    --header 'X-API-Key: password' \
    --header 'Content-Type: application/json' \
    -s | jq -r '.["edc:contractAgreementId"]')
echo $CONTRACT_AGREEMENT_ID
```

7) Transfering the asset
```console
curl -X POST "http://$CONSUMER_IP:8182/management/v3/transferprocesses" \
    --header "Content-Type: application/json" \
    --header 'X-API-Key: password' \
    -d @- <<-EOF
    {	
        "@context": {
            "edc": "https://w3id.org/edc/v0.0.1/ns/"
            },
        "@type": "TransferRequestDto",
        "connectorId": "consumer",
        "counterPartyAddress": "http://$PROVIDER_IP:8282/protocol",
        "protocol": "dataspace-protocol-http",
        "contractId": "$CONTRACT_AGREEMENT_ID",
        "protocol": "ids-multipart",
        "transferType": "IonosS3-PUSH",               
        "dataDestination": { 
            "type": "IonosS3",
            "bucketName": "company2",
            "path": "folder2/",
            "keyName" : "mykey"
       }
    }
EOF
```

After executing all the steps, we can now check the `<IONOS S3 Destination Bucket>` to see if the file has been correctly transfered.
