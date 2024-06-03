# Contract Negotiation

To perform a contract negotiation between two connectors, some steps need to be done:

## 0. Pre-requisites

You need to have deployed two EDC connectors (a consumer and a provider) and must be executed the [provision](../provision/README.md) steps on it.

## 1. Fetch the Catalog

The following command fetches the catalog on the consumer connector:

```bash
curl -X POST "http://$CONSUMER_HOST:$CONSUMER_MANAGEMENT_PORT/management/v2/catalog/request" \
  -H 'Content-Type: application/json' \
  -H 'X-API-Key: $CONSUMER_API_KEY' \
  -d '{
    "@context": {
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "counterPartyAddress": "http://$PROVIDER_HOST:$PROVIDER_PROTOCOL_PORT/protocol",
    "protocol": "dataspace-protocol-http"
  } ' -s | jq
```

Before executing the command, replace the following variables to its real values:
- $CONSUMER_HOST: the IP or DNS address to the consumer connector;
- $CONSUMER_MANAGEMENT_PORT: port of the management API on the consumer connector;
- $CONSUMER_API_KEY: default API key on the consumer connector;
- $PROVIDER_HOST: the IP or DNS address to the provider connector;
- $PROVIDER_PROTOCOL_PORT: port of the protocol API on the provider connector.

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
  "@id": "db82faf2-e91f-48d6-920a-a833c214998d",
  "@type": "dcat:Catalog",
  "dcat:dataset": {
    "@id": "asset-1",
    "@type": "dcat:Dataset",
    "odrl:hasPolicy": {
      "@id": "Y29udHJhY3QtNjQ=:YXNzZXQtNDAy:YmIwY2IzODctNDYyOC00ODhjLWFjYjEtYjRmZGU1NTNmNTdk",
      "@type": "odrl:Set",
      "odrl:permission": [],
      "odrl:prohibition": [],
      "odrl:obligation": [],
      "odrl:target": {
        "@id": "asset-1"
      }
    },
    "dcat:distribution": [],
    "name": "product description",
    "id": "asset-1",
    "contenttype": "application/json"
    },
    "dcat:service": {
      "@id": "25d20a99-cd40-467b-92d9-07608b317259",
      "@type": "dcat:DataService",
      "dct:terms": "connector",
      "dct:endpointUrl": "http://localhost:8282/protocol"
    },
    "participantId": "provider",
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

> Save the contents of the tag ``odrl:hasPolicy`` because it will be used in the next section.

## 2. Negotiate a Contract

The following command starts a contract negotiation between the consumer and provider connectors:

```bash
curl -X POST "http://$CONSUMER_HOST:$CONSUMER_MANAGEMENT_PORT/management/v2/contractnegotiations" \  
  -H 'Content-Type: application/json' \
  -H 'X-API-Key: $CONSUMER_API_KEY' \
  -d '{
    "@context":{
      "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
      "odrl": "http://www.w3.org/ns/odrl/2/"
    },
    "@type":"NegotiationInitiateRequestDto",
    "connectorId":"provider",
    "counterPartyAddress":"http://$PROVIDER_HOST:$PROVIDER_PROTOCOL_PORT/protocol",    
    "protocol":"dataspace-protocol-http",
    "policy":{
      $OFFER_POLICY
    }
  } ' -s | jq
```

Before executing the command, replace the following variables to its real values:
- $CONSUMER_HOST: the IP or DNS address to the consumer connector;
- $CONSUMER_MANAGEMENT_PORT: port of the management API on the consumer connector;
- $CONSUMER_API_KEY: default API key on the consumer connector;
- $PROVIDER_HOST: the IP or DNS address to the provider connector;
- $PROVIDER_PROTOCOL_PORT: port of the protocol API on the provider connector;
- $OFFER_POLICY: contents of the tag ``odrl:hasPolicy`` of the previous section output. 

Example:
```bash
curl -X POST 'http://localhost:8182/management/v2/contractnegotiations' \  
  -H 'Content-Type: application/json' \
  -H 'X-API-Key: pasword' \
  -d '{
    "@context":{
      "edc":"https://w3id.org/edc/v0.0.1/ns/",
      "odrl":"http://www.w3.org/ns/odrl/2/"
    },
    "@type":"NegotiationInitiateRequestDto",
    "connectorId":"provider",
    "counterPartyAddress":"http://localhost:9292/protocol",
    "protocol":"dataspace-protocol-http",
    "policy": {
      "@id": "Y29udHJhY3QtNjQ=:YXNzZXQtNDAy:Y2E5MGJlZjgtZmYwMC00OGJlLTk0MWItZmY2ZWYzNDFkZDJl",
      "@type": "odrl:Set",
      "odrl:permission": [],
      "odrl:prohibition": [],
      "odrl:obligation": [],
      "odrl:target": {
        "@id": "asset-1"
      }
    }   
  }' -s | jq
```

You will receive a response like bellow:
```json
{
  "@type": "IdResponse",
  "@id": "59cbd9fe-dbe0-494d-9ad5-a7311a146382",
  "createdAt": 1716207181122,
  "@context": {
    "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
    "edc": "https://w3id.org/edc/v0.0.1/ns/",
    "odrl": "http://www.w3.org/ns/odrl/2/"
  }
}
```

> Save the contents of the tag ``@id`` because it will be used in the next section.

## 3. Get the Contract Agreement

The following command queries the contract negotiation status on the consumer provider side:
```bash
curl -X GET "http://$CONSUMER_HOST:$CONSUMER_MANAGEMENT_PORT/management/v2/contractnegotiations/$NEGOTIATION_ID" \
    -H 'X-API-Key: $CONSUMER_API_KEY' \
    -s | jq
```

It returns the negotiation status and if the negotiation is FINALIZED, returns the contract agreement id.

Before executing the command, replace the following variables to its real values:
- $CONSUMER_HOST: the IP or DNS address to the consumer connector;
- $CONSUMER_MANAGEMENT_PORT: port of the management API on the consumer connector;
- $CONSUMER_API_KEY: default API key on the consumer connector;
- $NEGOTIATION_ID: contents of the tag ``@id`` of the previous section output.

Example:
```bash
curl -X GET 'http://localhost:8182/management/v2/contractnegotiations/59cbd9fe-dbe0-494d-9ad5-a7311a146382' \
  -H 'X-API-Key: password' \
  -s | jq
```

You will receive a response like bellow:
```json
{
  "@type": "ContractNegotiation",
  "@id": "eff52870-e5ab-497c-88f4-9eff5bf89d98",
  "type": "CONSUMER",
  "protocol": "dataspace-protocol-http",
  "state": "FINALIZED",
  "counterPartyId": "provider",
  "counterPartyAddress": "http://localhost:9292/protocol",
  "callbackAddresses": [],
  "createdAt": 1716211437072,
  "contractAgreementId": "9ffaf16a-463d-484b-9085-44170990b1aa",
  "@context": {
    "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
    "edc": "https://w3id.org/edc/v0.0.1/ns/",
    "odrl": "http://www.w3.org/ns/odrl/2/"
  }
}
```

> Save the contents of the tag ``contractAgreementId`` because it will be used in the next chapters.

[Next Chapter](../transfer/README.md)