# Push Data Transfer

To perform a push data transfer between two connectors, some steps need to be done:

## 0. Pre-requisites
You need to have deployed two EDC connectors (consumer and provider) and must be executed the [provision](../../provision/README.md) and [negotiation](../../negotiation/README.md) steps on it.

## 1. Start the Transfer

### 1.1 Using IONOS S3

The following command start a push transfer operation on the consumer connector, using a IONOS S3 Bucket to store to receive the provider transferred file:
```bash
curl -X POST "http://$CONSUMER_HOST:$CONSUMER_MANAGEMENT_PORT/management/v2/transferprocesses" \
  -H 'Content-Type: application/json' \
  -H 'X-API-Key: $CONSUMER_API_KEY' \
  -d '{
    "@context":{
      "edc":"https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type":"TransferRequestDto",
    "connectorId":"provider",
    "counterPartyAddress":"http://$PROVIDER_HOST:$PROVIDER_PROTOCOL_PORT/protocol",
    "contractId":"$AGREEMENT_ID",
    "assetId":"assetId-1",
    "protocol":"dataspace-protocol-http",
    "dataDestination":{
      "type":"IonosS3",
      "storage": "s3-eu-central-1.ionoscloud.com",
      "bucketName":"$BUCKET_NAME",
      "keyName":"keyname-1"
    }  
  } ' -s | jq
```

Before executing the command, replace the following variables to its real values:
- $CONSUMER_HOST: the IP or DNS address to the consumer connector;
- $CONSUMER_MANAGEMENT_PORT: port of the management API on the consumer connector;
- $CONSUMER_API_KEY: default API key on the consumer connector;
- $PROVIDER_HOST: the IP or DNS address to the provider connector;
- $PROVIDER_PROTOCOL_PORT: port of the protocol API on the provider connector;
- $AGREEMENT_ID: value of the tag ``contractAgreementId``, received in the [contract agreement](../../negotiation/README.md#3-get-the-contract-agreement) response;
- $BUCKET_NAME: name of the IONOS S3 bucket used to store to receive the provider transferred file.

Example:
```bash
curl -X POST 'http://localhost:8182/management/v2/catalog/request' \
  -H 'X-API-Key: password' \
  -H 'Content-Type: application/json' \
  -d '{
    "@context":{
      "edc":"https://w3id.org/edc/v0.0.1/ns/"
    },
    "counterPartyAddress":"http://localhost:9292/protocol",
    "protocol":"dataspace-protocol-http"
  }' -s | jq
```

You will receive a response like bellow:
```json
{
  "@type": "IdResponse",
  "@id": "e5d42e0b-0aea-42d1-bc9f-bc0b15b635c1",
  "createdAt": 1716212630807,
  "@context": {
    "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
    "edc": "https://w3id.org/edc/v0.0.1/ns/",
    "odrl": "http://www.w3.org/ns/odrl/2/"
  }
}
```

> Save the contents of the tag ``@id`` because it will be used in the next section.

## 2. Check Transfer Status

To check the transfer operation status, use the following command:
```bash
curl -X GET "http://$CONSUMER_HOST:$CONSUMER_MANAGEMENT_PORT/management/v2/transferprocesses/$TRANSFER_ID" \  
  -H 'X-API-Key: $CONSUMER_API_KEY' \
  -s | jq
```

Call this command until the transfer status is returned as TERMINATED.

Before executing the command, replace the following variables to its real values:
- $CONSUMER_HOST: the IP or DNS address to the consumer connector;
- $CONSUMER_MANAGEMENT_PORT: port of the management API on the consumer connector;
- $CONSUMER_API_KEY: default API key on the consumer connector;
- $TRANSFER_ID: contents of the tag ``@id`` of the previous section output.

Example:
```bash  
curl -X GET 'http://localhost:8182/management/v2/transferprocesses/e5d42e0b-0aea-42d1-bc9f-bc0b15b635c1' \
  -H 'X-API-Key: password'  \
  -s | jq
```

You will receive a response like bellow:
```json
{
  "@id": "e5d42e0b-0aea-42d1-bc9f-bc0b15b635c1",
  "@type": "TransferProcess",
  "correlationId": "d0476065-9559-4df2-8c31-c9b4e459f487",
  "state": "TERMINATED",
  "stateTimestamp": 1716214202918,
  "type": "CONSUMER",
  "assetId": "asset-602",
  "contractId": "db3f9a4c-b7a0-4cd7-981f-a7471c6bad04",
  "callbackAddresses": [],
  "dataDestination": {
    "@type": "DataAddress",
    "type": "IonosS3",
    "bucketName": "consumer-bucket",
    "keyName":"keyname-1"
  },
  "connectorId": "provider",
  "@context": {
    "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
    "edc": "https://w3id.org/edc/v0.0.1/ns/",
    "odrl": "http://www.w3.org/ns/odrl/2/"
  }
}
```

## 3. Transfer Deprovision

The following command perform the transfer deprovision, releasing all the resources used in the transfer process:

```bash
curl -X GET "http://$CONSUMER_HOST:$CONSUMER_MANAGEMENT_PORT/management/v2/transferprocesses/$TRANSFER_ID/deprovision" \
    -H 'X-API-Key: $CONSUMER_API_KEY' \
    -s | jq
```

Before executing the command, replace the following variables to its real values:
- $CONSUMER_HOST: the IP or DNS address to the consumer connector;
- $CONSUMER_MANAGEMENT_PORT: port of the management API on the consumer connector;
- $CONSUMER_API_KEY: default API key on the consumer connector;
- $TRANSFER_ID: contents of the tag ``@id`` of the [Start the Transfer](#1-start-the-transfer) section output.

Example:
```bash
curl -X POST 'http://localhost:8182/management/v2/transferprocesses/d0476065-9559-4df2-8c31-c9b4e459f487/deprovision' \
--header 'X-API-Key: password'
  -s | jq
```

You will receive an HTTP 200 response.