# IONOS EDC EXAMPLES
This repository contains examples of how to use the IONOS EDC (Ionos S3 extension, Nextcloud extension)



## Ionos S3 Extension

### [`file-transfer-multicloud`](./S3/file-transfer-multicloud)

Example of a file transfer between 1 connector using Azure Storage and another connector using IONOS S3.

### [`file-transfer-multiple-instances`](./S3/file-transfer-multiple-instances)

Example of a file transfer between 2 deployed connectors, using terraform script and the IONOS Cloud.

### [`file-transfer-persistence`](./S3/file-transfer-persistence)

Example of a file transfer between 2 connectors with both of them having IONOS S3 extension and PostgreSQL database to persist the EDC's internal data.

### [`file-transfer-pull`](./S3/file-transfer-pull)

Example of a file transfer between 1 standard connector and another one using the IONOS S3 extension.

### [`file-transfer-push`](./S3/file-transfer-push)

Example of a file transfer between 2 connectors with both of them having IONOS S3 extension.

### [`file-trasfer-push-daps`](./S3/file-trasfer-push-daps)

Example of a file transfer using DAPS

## Ionos Nextcloud Extension

### [`file-share-between-2-nextcloud-accounts`](./Nextcloud/file-share-between-2-nextcloud-accounts)
Example of a file share between two EDC's using two different Nextcloud's accounts.

### [`file-transfer-between-2-nextcloud`](./Nextcloud/file-transfer-between-2-nextcloud)
Example of a file transfer between two EDC's using two different Nextcloud's instances.

## MISC
### ['file-transfer-ionosS3-nextcloud'](./misc/file-transfer-ionosS3-nextcloud)
Example of a file transfer between 2 connectors with one using IONOS S3 extension and the other using Nextcloud extension.