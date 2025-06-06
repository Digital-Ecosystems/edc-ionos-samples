# File transfer using push method 

 This example shows how to exchange a data file between two EDC's. It is based on a sample of the official EDC respository.

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
2) Create the required buckets: access the `Storage\Object Storage\S3 Web Console` option and create two buckets: company1;
3) Upload a file named `device1-data.csv` into the company1 bucket. You can use the `example/file-transfer-push/device1-data.csv`;
4) Create a token that the consumer will use to do the provisioning. Take a look at this [documentation](https://github.com/ionos-cloud/edc-ionos-s3/blob/main/ionos_token.md);
5) Copy the required configuration fields:  
Consumer: open the `s3/file-transfer-push/consumer/resources/consumer-config.properties` (or use an Hashicorp Vault instance) and add the field `edc.ionos.token` with the token;   
Provider: open the `s3/file-transfer-push/provider/resources/provider-config.properties` (or use an Hashicorp Vault instance) and insert the key - `edc.ionos.access.key` and the secret - `edc.ionos.secret.access.key` (step 1);

Note: by design, S3 technology allows only unique names for the buckets. You may find an error saying that the bucket name already exists.


## Usage

Local execution:
```bash
java -Dedc.fs.config=s3/file-transfer-push/consumer/resources/consumer-config.properties -jar s3/file-transfer-push/consumer/build/libs/dataspace-connector.jar
java -Dedc.fs.config=s3/file-transfer-push/provider/resources/provider-config.properties -jar s3/file-transfer-push/provider/build/libs/dataspace-connector.jar
```

or

```bash
docker compose -f "docker-compose.yml" up --build
```
If you use docker to do the deployment of this example, don't forget to replace `localhost` with `consumer` and `provider` in the curls below.

We will have to call some URL's in order to transfer the file:
1) Contract offers
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
			"@id": "Y29udHJhY3QtNjIz:YXNzZXQtMTU0:MzBiMTlhMmQtNmE2Ni00MjVjLThmZmYtMDZhZmE0NGY1YTdj",
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
		"dct:endpointUrl": "http://localhost:8282/protocol"
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

Copy the `policy{ @id` from the response of the first curl into this curl and execute it.

```
curl --location --request POST 'http://localhost:9192/management/v3/contractnegotiations' \
     --header 'X-API-Key: password' \
     --header 'Content-Type: application/json' \
     --data-raw '{
          "@context":{
          "edc":"https://w3id.org/edc/v0.0.1/ns/",
          "odrl":"http://www.w3.org/ns/odrl/2/"
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
	"edc:counterPartyAddress": "http://localhost:8282/protocol",
	"edc:callbackAddresses": [],
	"edc:contractAgreementId": "044b5483-7681-4e11-bd9a-675063caff28",
	"@context": {
		"dct": "https://purl.org/dc/terms/",
		"edc": "https://w3id.org/edc/v0.0.1/ns/",
		"dcat": "https://www.w3.org/ns/dcat/",
		"odrl": "http://www.w3.org/ns/odrl/2/",
		"dspace": "https://w3id.org/dspace/v0.8/"
	}
}
```

4) File transfer

Copy the value of the `edc:contractAgreementId` from the response of the previous curl into this curl and execute it.
```

curl -X POST "http://localhost:9192/management/v3/transferprocesses" \
        --header "Content-Type: application/json" \
        --header 'X-API-Key: password' \
        --data '{	
                "@context": {
                    "edc": "https://w3id.org/edc/v0.0.1/ns/"
                    },

                "connectorId": "consumer",
                "counterPartyAddress": "http://localhost:8282/protocol",
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