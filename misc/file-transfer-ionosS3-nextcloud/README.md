#File transfer between two different clouds

This example shows how to exchange a data file between two EDC's using two Nextcloud and Ionos Cloud

The consumer will use the Nextcloud and the provider will use IonosS3.

It is based on [this](https://github.com/eclipse-edc/Samples/blob/main/transfer/transfer-05-file-transfer-cloud/README.md) EDC example and it will execute the connector locally.

## Requirements

You will need the following:
- Nextcloud account;
- Java Development Kit (JDK) 17 or higher;
- Docker;
- GIT;
- Linux shell or PowerShell;


### Building the project

Just check the `Building and Running` section of the previous [readme](../../README.md).

### Configuration
In order to configure this example, please follow this steps:

## Usage

Local execution:

```bash
java -Dedc.fs.config=example/file-transfer-between-2-nextcloud/consumer/resources/config.properties -jar example/file-transfer-between-2-nextcloud/consumer/build/libs/dataspace-connector.jar

java -Dedc.fs.config=example/file-transfer-between-2-nextcloud/provider/resources/config.properties -jar example/file-transfer-between-2-nextcloud/provider/build/libs/dataspace-connector.jar
```

We will have to call some URL's in order to transfer the file:

1) Asset creation for the consumer
```console
curl -d '{
			"@context": {
             "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
           },
            "@id": "assetId",
		    "properties": {
            },
           "dataAddress": {
             "type": "IonosS3",
				"storage":"s3-eu-central-1.ionoscloud.com",
				"bucketName": "company2",
				"keyName" : "device1-data.csv"
           }
         }'  -H 'X-API-Key: password' \
		 -H 'content-type: application/json' http://localhost:8182/management/v3/assets
```

2) Policy creation
```console
curl -d '{
                  "@context":{
                        "edc":"https://w3id.org/edc/v0.0.1/ns/",
                        "odrl":"http://www.w3.org/ns/odrl/2/"
                     },
                 "@id": "aPolicy",
                 "policy": {
                 "@type": "odrl:use",
                   "odrl:prohibition":[
                 {
                     "odrl:target": "assetId",
                      "odrl:action": {
                             "odrl:type": "USE"
                         },
                         "odrl:edctype": "dataspaceconnector:prohibition",
                 "odrl:constraint": [{
                     "odrl:leftOperand": "downloadable",
                     "odrl:operator": { 
                          "@id": "odrl:eq"              
                         },
                     "odrl:rightOperand": "true",
                     "odrl:comment": "if is downloadable "
                   }
                 ]
                 }
                 ]
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
           "assetsSelector": []
         }' -H 'X-API-Key: password' \
 -H 'content-type: application/json' http://localhost:8182/management/v2/contractdefinitions
```

4) Fetching the catalog
```console
curl -X POST "http://localhost:9192/management/v2/catalog/dataset/request" \
--header 'X-API-Key: password' \
--header 'Content-Type: application/json' \
-d '{
         "@context":{
           "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
         },
         "@type": "DatasetRequest",
         "@id": "assetId",
         "counterPartyAddress":"http://localhost:8282/protocol",
         "protocol":"dataspace-protocol-http"
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
	"@context":{
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
     "odrl": "http://www.w3.org/ns/odrl/2/"
   },
   @type":"NegotiationInitiateRequestDto",
   "counterPartyAddress":"http://localhost:8282/protocol",
   "providerId":"consumer",
   "protocol":"dataspace-protocol-http",
   "policy":{
      "@id":"{{offerId}}",
      "@type": "odrl:Set",
      "odrl:permission": [],
      "odrl:prohibition": {
            "odrl:target": "assetId",
            "odrl:action": {
                "odrl:type": "USE"
            },
            "odrl:constraint": {
                "odrl:leftOperand": "downloadable",
                "odrl:operator": {
                    "@id": "odrl:eq"
                },
                "odrl:rightOperand": "true"
            }
        },
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
			   "@type":"TransferRequestDto",
               "connectorId":"provider",
               "counterPartyAddress":"http://localhost:8282/protocol",
               "protocol":"dataspace-protocol-http",
               "contractId":"{{agreementId}}",
               "assetId":"assetId",
				"dataDestination": { 
					"type": "Nextcloud",
                    "filePath": "pl",
                    "fileName": "device1-data.csv",
                    "keyName" : "device1-data.csv"
				}
        }'
```
Note: copy the `id` field to do the deprovisioning;

8) Deprovisioning

```
curl -X POST -H 'X-Api-Key: password' "http://localhost:9192/management/v2/transferprocesses/{<ID>}/deprovision"
```
