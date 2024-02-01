# File Share between 2 Nextcloud accounts

This example shows how to share file/folder between two EDC's using two different Nextcloud Accounts.

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

<details><summary>Policy configuration</summary>

| Parameter name       | Description                      | Option's                                                                                                       | Mandatory                                            |
|----------------------|----------------------------------|----------------------------------------------------------------------------------------------------------------|------------------------------------------------------|
| `shareWith`          | Identification of user we want to share | user / group id / email address / circleID / conversation name with which the file should be shared            | Yes                                                  |
| `shareType`          | Type of sharing, this option must match the previous option, for example: if choosing 'user,' then shareType should be 0; if choosing 'email address,' then shareType should be 4.                 | 0 = user; 1 = group; 3 = public link; 4 = email; 6 = federated cloud share; 7 = circle; 10 = Talk conversation | Yes             |
| `permissionType`    |   Permission level, if the user can only read the file, then permissionType=1; if the user can update the file/folder, then permissionType=2.                         | 1 = read; 2 = update; 4 = create; 8 = delete; 16 = share; 31 = all (default: 31, for public shares: 1          | Yes |
| `expirationTime` |          set a expire date for public link shares. This argument expects a well formatted date string, e.g. ‘YYYY-MM-DD’                        | -                                                                                                              | Yes                |
</details>


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
		"odrl:prohibition": [],
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
