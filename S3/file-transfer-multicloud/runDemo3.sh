#!/bin/bash

curl -d '{
           "asset": {
             "properties": {
               "asset:prop:id": "assetId",
               "asset:prop:name": "product description",
               "asset:prop:contenttype": "application/json"
             }
           },
           "dataAddress": {
             "properties": {
			 "type": "AzureStorage",
				"account": "<storage-account-name>",
				"container": "src-container",
				"blobname": "device1-data.csv",
				"keyName" : "<storage-account-name>-key1"
             }
           }
         }'  -H 'X-API-Key: password' \
		 -H 'content-type: application/json' http://localhost:8182/management/v3/assets/

curl -d '{
           "id": "aPolicy",
           "policy": {
             "uid": "231802-bb34-11ec-8422-0242ac120002",
             "permissions": [
               {
                 "target": "assetId",
                 "action": {
                   "type": "USE"
                 },
                 "edctype": "dataspaceconnector:permission"
               }
             ],
             "@type": {
               "@policytype": "set"
             }
           }
         }' -H 'X-API-Key: password' \
		 -H 'content-type: application/json' http://localhost:8182/management/v3/policydefinitions


 curl -d '{
   "id": "1",
   "accessPolicyId": "aPolicy",
   "contractPolicyId": "aPolicy",
   "criteria": []
 }' -H 'X-API-Key: password' \
 -H 'content-type: application/json' http://localhost:8182/management/v3/contractdefinitions
 
curl -X POST "http://localhost:9192/management/v3/catalog/request" \
--header 'X-API-Key: password' \
--header 'Content-Type: application/json' \
--data-raw '{
  "providerUrl": "http://localhost:8282/api/v1/ids/data"
}'

contractId=`curl -d '{
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
                         }' --header 'X-API-Key: password' \
		 -X POST -H 'content-type: application/json' http://localhost:9192/management/v3/contractnegotiations\
         -s | jq -r '.id'`

echo "PJC: "$contractId


sleep 4

contractAgreementId=`curl -X GET "http://localhost:9192/api/v1/management/contractnegotiations/$contractId" \
	--header 'X-API-Key: password' \
    --header 'Content-Type: application/json' \
    -s | jq -r '.contractAgreementId'`
#    -s | jq `

echo "PJC - contractAgreementId: "$contractAgreementId



sleep 4

deprovisionId=`curl -X POST "http://localhost:9192/management/v3/transferprocesses" \
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
                   }' \
    -s | jq -r '.id'`
	
sleep 10
curl -X POST -H 'X-Api-Key: password' "http://localhost:9192/api/v1/management/transferprocess/$deprovisionId/deprovision"

echo "DONE"
