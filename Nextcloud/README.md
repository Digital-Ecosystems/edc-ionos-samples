## Folders Description

### `file-share-between-2-nextcloud-accounts`
Contains an example, of two connectors, that does `NOT` transfer a file but uses a share mechanism from Nextcloud instead. It is used only one instance of Nextcloud.

### `file-transfer-between-2-nextcloud`
Contains an example that transfers a file between 2 connectors. Two instances of Nextcloud are used.

## Running Nextcloud
If you want to have Nextcloud running on your IONOS Cloud, you can purchase it by clicking [here](https://www.ionos.de/cloud/cloud-apps/nextcloud?ar=1). 

For development purpose (or if you just want to test this OSS), you can run it locally using Docker:

```
 docker pull nextcloud

 docker run -d -p 8080:80 nextcloud
```
