# File transfer using push method - with persistency

 This example shows how to exchange a data file between two EDC's. It is based on a sample of the official EDC respository. The examples uses PostgreSQL for persistence.

 You can execute this example by using only one IONOS account (more for development purpose) or by using two IONOS accounts (similar to production purpose).

## Requirements

You will need the following:
- IONOS account;
- Java Development Kit (JDK) 17 or higher;
- Docker;
- GIT;
- Linux shell or PowerShell;

## Deployment

### Building the project

Just check the `Building and Running` section of the previous [readme](https://github.com/ionos-cloud/edc-ionos-s3).

### Configuration
In order to configure this sample, please follow this steps:
(We will use the [DCD](https://dcd.ionos.com))
1) Create a S3 Key Management: access the `Storage\Object Storage\S3 Key Management` option and generate a Key. Keep the key and the secret;
2) Create the required buckets: access the `Storage\Object Storage\S3 Web Console` option and create two buckets: company1 and company2;
3) Upload a file named `device1-data.csv` into the company1 bucket. You can use the `s3/file-transfer-persistence/device1-data.csv`;
4) Create a token that the consumer will use to do the provisioning. Take a look at this [documentation](https://github.com/ionos-cloud/edc-ionos-s3/blob/main/ionos_token.md);
5) Copy the required configuration fields:  
Consumer: open the `s3/file-transfer-persistence/consumer/resources/consumer-config.properties` (or use an Hashicorp Vault instance) and add the field `edc.ionos.token` with the token;
Provider: open the `s3/file-transfer-persistence/provider/resources/provider-config.properties` (or use an Hashicorp Vault instance) and insert the key - `edc.ionos.access.key` and the secret - `edc.ionos.secret.access.key` (step 1);

Note: by design, S3 technology allows only unique names for the buckets. You may find an error saying that the bucket name already exists.


## Usage

```bash
docker compose -f "docker-compose.yml" up --build
```
We will have to call some URL's in order to transfer the file:
1) Contract offers
```console
curl -X POST "http://localhost:9192/management/v3/catalog/request" \
--header 'X-API-Key: password' \
--header 'Content-Type: application/json' \
-d '{
      "@context": {
        "edc": "https://w3id.org/edc/v0.0.1/ns/"
      },
      "providerUrl": "http://provider:8282/protocol",
      "protocol": "dataspace-protocol-http"
    }'-s | jq -r
```

You will have an output like the following:

```
{
	"@id": "51dde18d-dc81-41ed-b110-591fdcea753f",
	"@type": "dcat:Catalog",
	"dcat:dataset": {
		"@id": "6519fb05-c1f3-4a81-a4c5-93f5ab128a22",
		"@type": "dcat:Dataset",
		"odrl:hasPolicy": {
			"@id": "1:1:67e38ac2-26e0-40c0-9628-e864f4e260f7",
			"@type": "odrl:Set",
			"odrl:permission": {
				"odrl:target": "1",
				"odrl:action": {
					"odrl:type": "USE"
				}
			},
			"odrl:prohibition": [],
			"odrl:obligation": [],
			"odrl:target": "1"
		},
		"dcat:distribution": [],
		"edc:id": "1"
	},
	"dcat:service": {
		"@id": "80e665f9-85f1-4ede-b2b5-0df6ed2d5ee3",
		"@type": "dcat:DataService",
		"dct:terms": "connector",
		"dct:endpointUrl": "http://provider:8282/protocol"
	},
	"edc:participantId": "provider",
	"@context": {
		"dct": "https://purl.org/dc/terms/",
		"edc": "https://w3id.org/edc/v0.0.1/ns/",
		"dcat": "https://www.w3.org/ns/dcat/",
		"odrl": "http://www.w3.org/ns/odrl/2/",
		"dspace": "https://w3id.org/dspace/v0.8/"
	}
}
```

2) Contract negotiation

Copy the `odrl:hasPolicy{ @id` from the response of the first curl into this curl and execute it.

```
curl --location --request POST 'http://localhost:9192/management/v3/contractnegotiations' \
--header 'X-API-Key: password' \
--header 'Content-Type: application/json' \
--data-raw '{
            "@context": {
               "edc": "https://w3id.org/edc/v0.0.1/ns/",
               "odrl": "http://www.w3.org/ns/odrl/2/"
             },
            "counterPartyAddress": "http://localhost:8282/protocol",
            "protocol": "dataspace-protocol-http",
            "policy": {
                  "@context": "http://www.w3.org/ns/odrl.jsonld",
                  "@id": "Y29udHJhY3QtNjIz:YXNzZXQtMTU0:MzBiMTlhMmQtNmE2Ni00MjVjLThmZmYtMDZhZmE0NGY1YTdj",
                  "@type": "Offer",
                  "assigner": "provider",
                  "target": "asset-154"
            }
     }'
```

You will have an answer like the following:
```
{
	"@type": "edc:IdResponseDto",
	"@id": "a88180b3-0d66-41b5-8376-c91d8253afcf",
	"edc:createdAt": 1687364689704,
	"@context": {
		"dct": "https://purl.org/dc/terms/",
		"edc": "https://w3id.org/edc/v0.0.1/ns/",
		"dcat": "https://www.w3.org/ns/dcat/",
		"odrl": "http://www.w3.org/ns/odrl/2/",
		"dspace": "https://w3id.org/dspace/v0.8/"
	}
}
```

3) Contact Agreement id

Copy the value of the `@id` from the response of the previous curl into this curl and execute it.
```
curl -X GET -H 'X-Api-Key: password' "http://localhost:9192/management/v3/contractnegotiations/{<ID>}"
```
You will have an answer like the following:
```
{
	"@type": "edc:ContractNegotiationDto",
	"@id": "a88180b3-0d66-41b5-8376-c91d8253afcf",
	"edc:type": "CONSUMER",
	"edc:protocol": "dataspace-protocol-http",
	"edc:state": "FINALIZED",
	"edc:counterPartyAddress": "http://provider:8282/protocol",
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

4) Crashing an EDC:

Let's simulate a crash of a connector.
```
docker stop file-transfer-persistence-provider-1
```

Let's check the database to see if the asset has been persisted.
```sh
docker exec -it edc-db-provider psql -U postgres -c "select * from edc_contract_negotiation;"
```

You will have an answer like the following:
```sh
                  id                  |  created_at   |  updated_at   |            correlation_id            | counterparty_id |     counterparty_address      |        protocol         |   type   | state | state_count | state_timestamp | error_detail |               agreement_id               |                                                                                                                                                                                                                          contract_offers                                                                                                                                                                                                                           | callback_addresses | trace_context | lease_id 
--------------------------------------+---------------+---------------+--------------------------------------+-----------------+-------------------------------+-------------------------+----------+-------+-------------+-----------------+--------------+------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------+---------------+----------
 34ebb7ca-250d-4def-9270-27eea4ec1d96 | 1699602880839 | 1699602882759 | 1ca28ca9-8a7a-4318-97bd-66f9ba45392a | consumer        | http://consumer:9292/protocol | dataspace-protocol-http | PROVIDER |  1200 |           1 |   1699602882759 |              | 1:1:fc089674-ecb2-4910-a593-55e3a59784a1 | [{"id":"1:1:a345ad85-c240-4195-b954-13841a6331a1","policy":{"permissions":[{"edctype":"dataspaceconnector:permission","target":"1","action":{"type":"USE","includedIn":null,"constraint":null},"assignee":null,"assigner":null,"constraints":[],"duties":[]}],"prohibitions":[],"obligations":[],"extensibleProperties":{},"inheritsFrom":null,"assigner":null,"assignee":null,"target":"1","@type":{"@policytype":"set"}},"assetId":"1","providerId":"provider"}] | []                 | {}            | 
(1 row)
```

Let's resume the file transfer process.
```
docker start file-transfer-persistence-provider-1
```

5) File transfer

Copy the value of the `edc:contractAgreementId` from the response of the previous curl into this curl and execute it.
```

curl -X POST "http://localhost:9192/management/v3/transferprocesses" \
    --header "Content-Type: application/json" \
    --header 'X-API-Key: password' \
    --data '{	
            "@context": {
                "edc": "https://w3id.org/edc/v0.0.1/ns/"
            },
            "@type": "TransferRequestDto",
            "connectorId": "consumer",
            "counterPartyAddress": "http://provider:8282/protocol",
            "protocol": "dataspace-protocol-http",
            "contractId": "<CONTRACT AGREEMENT ID>",
             "transferType": "IonosS3-PUSH",               
                "dataDestination": { 
                    "type": "IonosS3",
                    "bucketName": "company2",
                    "path": "folder2/",
                    "keyName" : "mykey"
                 }
        }'
```
You will have an answer like the following:
```
{
	"@type": "edc:IdResponseDto",
	"@id": "f9083e20-61a7-41c3-87f2-964de0ed2f52",
	"edc:createdAt": 1687364842252,
	"@context": {
		"dct": "https://purl.org/dc/terms/",
		"edc": "https://w3id.org/edc/v0.0.1/ns/",
		"dcat": "https://www.w3.org/ns/dcat/",
		"odrl": "http://www.w3.org/ns/odrl/2/",
		"dspace": "https://w3id.org/dspace/v0.8/"
	}
}
```

After executing all the steps, we can now check the `company2` bucket of our IONOS S3 to see if the file has been correctly transfered.


Deprovisioning 

```
curl -X POST -H 'X-Api-Key: password' "http://localhost:9192/management/v3/transferprocesses/{<ID>}/deprovision"
```