# File transfer between two different clouds

 This example shows how to exchange a data folders between two Ionos EDC's 


 It is based on [this](https://github.com/eclipse-edc/Samples/blob/main/transfer/transfer-05-file-transfer-cloud/README.md) EDC example and it will execute the connector locally.

## Requirements

You will need the following:
- IONOS account;
- Java Development Kit (JDK) 17 or higher;
- Terraform;
- Docker;
- GIT;
- Linux shell or PowerShell;

## Deployment

### Building the project

Just check the `Building and Running` section of the previous [readme](../../README.md).

### Configuration
In order to configure this example, please follow this steps:  


`IONOS S3`
(We will use the [DCD](https://dcd.ionos.com))
1) Create a S3 Key Management: access the `Storage\Object Storage\S3 Key Management` option and generate a Key. Keep the key and the secret;
2) Create the required buckets: access the `Storage\Object Storage\S3 Web Console` option and create two buckets: company1;
3) Upload a file named `device1-data.csv` into the company1 bucket. You can use the `s3/file-transfer-push/device1-data.csv`;
4) Create a token that the consumer will use to do the provisioning. Take a look at this [documentation](../../ionos_token.md);
5) Copy the required configuration fields:  
   Consumer: open the `s3/folder-transfer-push/consumer/resources/consumer-config.properties` (or use an Hashicorp Vault instance) and add the field `edc.ionos.token` with the token;   
   Provider: open the `s3/folder-transfer-push/provider/resources/provider-config.properties` (or use an Hashicorp Vault instance) and insert the key - `edc.ionos.access.key` and the secret - `edc.ionos.secret.access.key` (step 1);

`Hashicorp Vault`
```console
edc.vault.hashicorp.url=<VAULT_ADDRESS:VAULT_PORT>
edc.vault.hashicorp.token=<ROOT_TOKEN>
edc.vault.hashicorp.timeout.seconds=30
```
Note: 
- the Hashicorp vault will have the required data for the both connectors;
- the `edc.vault.hashicorp.url` is the address of the Hashicorp Vault;
- the `edc.vault.hashicorp.token` is the root token of the Hashicorp Vault;
- 

## Usage

Local execution:
```bash
java -Dedc.fs.config=s3/file-transfer-multicloud/consumer/resources/consumer-config.properties -jar example/file-transfer-multicloud/consumer/build/libs/dataspace-connector.jar

java -Dedc.fs.config=s3/file-transfer-multicloud/provider/resources/provider-config.properties -jar example/file-transfer-multicloud/provider/build/libs/dataspace-connector.jar
```

or

```bash
docker compose -f "docker-compose.yml" up --build
```
If you use docker to do the deployment of this example, don't forget to replace `localhost` with `consumer` and `provider` in the curls below.

We will have to call some URL's in order to transfer the file:
  

1) Asset creation for the consumer
```console
curl -d '{
			"@context": {
              "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
           },
     
            "@id": "assetId",
			"properties": {
              
               "name": "product description",
               "contenttype": "application/json"
            },
           "dataAddress": {
			    "type": "IonosS3",
				"storage": "s3-eu-central-1.ionoscloud.com",
				"bucketName": "mybucket",
				"blobname": "folder1/",
				"filterIncludes": "device1-data.csv",
				"filterExcludes": "device2-data.csv",
				"keyName" : "mykey"
            
           }
         }'  -H 'X-API-Key: password' \
		 -H 'content-type: application/json' http://localhost:8182/management/v3/assets
```
Note: for more details about dataAddress fields, please take a look at the [documentation](url)

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
		 -H 'content-type: application/json' http://localhost:8182/management/v2/policydefinitions
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
              "assetsSelector":[{  "operandLeft": "id", "operator": "=", "operandRight": "assetId" }]
         }' -H 'X-API-Key: password' \
 -H 'content-type: application/json' http://localhost:8182/management/v2/contractdefinitions
```

4) Fetching the catalog
```console
curl -X POST "http://localhost:9192/management/v2/catalog/request" \
--header 'X-API-Key: password' \
--header 'Content-Type: application/json' \
-d '{
      "@context": {
        "edc": "https://w3id.org/edc/v0.0.1/ns/"
      },
      "providerUrl": "http://localhost:8282/protocol",
      "protocol": "dataspace-protocol-http"
    }'
```
You will have an answer like the following:
```
{
	"@type": "edc:ContractNegotiationDto",
	"@id": "a88180b3-0d66-41b5-8376-c91d8253afcf",
	"edc:type": "CONSUMER",
	"edc:protocol": "dataspace-protocol-http",
	"edc:state": "FINALIZED",
	"edc:counterPartyAddress": "http://localhost:8282/protocol",
	"edc:callbackAddresses": [],
	"edc:contractAgreementId": "1:1:5c0a5d3c-69ea-4fb5-9d3d-e33ec280cde9",
	"@context": {
		"dct": "https://purl.org/dc/terms/",
		"edc": "https://w3id.org/edc/v0.0.1/ns/",
		"dcat": "https://www.w3.org/ns/dcat/",
		"odrl": "http://www.w3.org/ns/odrl/2/",
		"dspace": "https://w3id.org/dspace/v0.8/"
	}
}
```

5) Contract negotiation
Copy the `policy{ @id` from the response of the first curl into this curl and execute it.

```
curl --location --request POST 'http://localhost:9192/management/v2/contractnegotiations' \
--header 'X-API-Key: password' \
--header 'Content-Type: application/json' \
--data-raw '{
	"@context": {
    "edc": "https://w3id.org/edc/v0.0.1/ns/",
    "odrl": "http://www.w3.org/ns/odrl/2/"
  },
  "@type": "NegotiationInitiateRequestDto",
  "consumerId":"consumer",
  "providerId":"provider",
  "connectorAddress": "http://localhost:8282/protocol",
  "protocol": "dataspace-protocol-http",
  "offer": {
    "offerId": "1:1:a345ad85-c240-4195-b954-13841a6331a1",
    "assetId": "assetId",
    "policy": {
            "@id":<"REPLACE WHERE">,
			 "@type": "odrl:Set",
      "odrl:permission": [],
      "odrl:prohibition": [],
      "odrl:obligation": [],
      "odrl:target": {
         "@id": "assetId"
      }
  }
}'
```

Note: copy the `id` field;

6) Contract agreement

Copy the value of the `id` from the response of the previous curl into this curl and execute it.
```console
curl -X GET "http://localhost:9192/management/v2/contractnegotiations/{<ID>}" \
	--header 'X-API-Key: password' \
    --header 'Content-Type: application/json' \
    -s | jq
```
You will have an answer like the following:
```
{
	"@type": "edc:ContractNegotiationDto",
	"@id": "a88180b3-0d66-41b5-8376-c91d8253afcf",
	"edc:type": "CONSUMER",
	"edc:protocol": "dataspace-protocol-http",
	"edc:state": "FINALIZED",
	"edc:counterPartyAddress": "http://localhost:8282/protocol",
	"edc:callbackAddresses": [],
	"edc:contractAgreementId": "1:1:5c0a5d3c-69ea-4fb5-9d3d-e33ec280cde9",
	"@context": {
		"dct": "https://purl.org/dc/terms/",
		"edc": "https://w3id.org/edc/v0.0.1/ns/",
		"dcat": "https://www.w3.org/ns/dcat/",
		"odrl": "http://www.w3.org/ns/odrl/2/",
		"dspace": "https://w3id.org/dspace/v0.8/"
	}
}
```

Note: copy the `contractAgreementId` field;

7) Transfering the asset

Copy the value of the `contractAgreementId` from the response of the previous curl into this curl and execute it.
```console
curl -X POST "http://localhost:9192/management/v2/transferprocesses" \
    --header "Content-Type: application/json" \
	--header 'X-API-Key: password' \
    --data '{	
				"@context": {
					"edc": "https://w3id.org/edc/v0.0.1/ns/"
					},
				"@type": "TransferRequestDto",
                "connectorId": "consumer",
                "connectorAddress": "http://localhost:8282/protocol",
				"protocol": "dataspace-protocol-http",
                "contractId": "<CONTRACT AGREEMENT ID>",
                "assetId": "assetId",
				"dataDestination": { 
					"type": "IonosS3",
					"storage":"s3-eu-central-1.ionoscloud.com",
					"bucketName": "company2",
					"path2": "folder2/",
					"keyName" : "mykey"
				
				
				}
        }'
```
Note_1: for more details about dataDestination fields, please take a look at the [documentation](url)
Note_2: copy the `id` field to do the deprovisioning;

Accessing the bucket on the IONOS S3, you will see the `device1-data.csv` file.

8) Deprovisioning 

```
curl -X POST -H 'X-Api-Key: password' "http://localhost:9192/management/v2/transferprocesses/{<ID>}/deprovision"
```

Note: this will delete the IONOS S3 token from IONOS Cloud.
