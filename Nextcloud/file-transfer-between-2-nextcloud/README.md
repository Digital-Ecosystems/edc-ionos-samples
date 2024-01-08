#File transfer between two different clouds

This example shows how to exchange a data file between two EDC's using two different Nextcloud's: Nextcloud.

The consumer will use the Nextcloud and the provider will use Nextcloud.

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
java -Dedc.fs.config=./consumer/resources/config.properties -jar ./consumer/build/libs/connector.jar

java -Dedc.fs.config=./provider/resources/config.properties -jar ./provider/build/libs/connector.jar
```

We will have to call some URL's in order to transfer the file:

1) Asset creation for the consumer
```console
curl -d @jsons/asset.json -H 'X-API-Key: password' \
		 -H 'content-type: application/json' http://localhost:8182/management/v3/assets
```

2) Policy creation
```console
curl -d @jsons/create-policy.json -H 'X-API-Key: password' \
		 -H 'content-type: application/json' http://localhost:8182/management/v2/policydefinitions
```

3) Contract creation
```console
curl -d @jsons/create-contract.json -H 'X-API-Key: password' \
 -H 'content-type: application/json' http://localhost:8182/management/v2/contractdefinitions
```

4) Fetching the catalog
```console
curl -X POST "http://localhost:9192/management/v2/catalog/dataset/request" \
--header 'X-API-Key: password' \
--header 'Content-Type: application/json' \
-d @jsons/fetch-catalog.json
```
You will have an answer like the following:
```
{
	"@id": "asset-1",
	"@type": "dcat:Dataset",
	"odrl:hasPolicy": {
		"@id": "Y29udHJhY3QtMQ==:YXNzZXQtMQ==:MzIxMGUwNTQtYzYxYy00N2VhLTg4MmMtYTc0NTJmNDYxM2Fi",
		"@type": "odrl:Set",
		"odrl:permission": [],
		"odrl:prohibition": {
			"odrl:target": "asset-1",
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
			"@id": "asset-1"
		}
	},
	"dcat:distribution": [],
	"id": "asset-1",
	"@context": {
		"@vocab": "https://w3id.org/edc/v0.0.1/ns/",
		"edc": "https://w3id.org/edc/v0.0.1/ns/",
		"dcat": "https://www.w3.org/ns/dcat/",
		"dct": "https://purl.org/dc/terms/",
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
-d @jsons/contract-negotiation.json
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
    -d @jsons/transfer.json
```
Note: copy the `id` field to do the deprovisioning;

8) Deprovisioning

```
curl -X POST -H 'X-Api-Key: password' "http://localhost:9192/management/v2/transferprocesses/{<ID>}/deprovision"
```
