# rook-ceph

https://rook.io/docs/rook/v1.2/ceph-common-issues.html

## Toolbox

```bash
kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') bash
```

## Crashes

Sometime ceph will report a `HEALTH_WARN` even when the health is fine, in order to get ceph to report back healthly do the following...

```bash
ceph crash ls
# if you want to read the message
ceph crash info <id>
# archive crash report
ceph crash archive <id>
# or, archive all crash reports
ceph crash archive-all
```

## Migration

In your shell...

```bash
# Scale app to 0 replicas
kubectl scale deploy/zigbee2mqtt --replicas 0 -n home

# Get RBD image name for the app
kubectl get pv/(k get pv | grep zigbee2mqtt-data | awk -F' ' '{print $1}') -n home -o json | jq -r '.spec.csi.volumeAttributes.imageName'
# csi-vol-e4a2e40f-2795-11eb-80c7-2298c6796a25
```

In another shell tab...

```bash
kubectl -n rook-ceph exec -it (kubectl -n rook-ceph get pod -l "app=rook-direct-mount" -o jsonpath='{.items[0].metadata.name}') bash

# create mount directories
mkdir -p /mnt/{tmp,Data}

# mount nfs with backups
mount -t nfs -o "tcp,intr,rw,noatime,nodiratime,rsize=1048576,wsize=1048576,hard" 192.168.1.40:/volume1/Data /mnt/Data

# optional list rbds
rbd list --pool replicapool

rbd map -p replicapool csi-vol-e4a2e40f-2795-11eb-80c7-2298c6796a25
mount /dev/rbd0 /mnt/tmp

tar xvf /mnt/Data/backups/zigbee2mqtt.tar.gz -C /mnt/tmp
chown -R 568:568 /mnt/tmp/

umount /mnt/tmp
rbd unmap -p replicapool csi-vol-e4a2e40f-2795-11eb-80c7-2298c6796a25
```

## Buckets

Create a `BucketObjectClaim` with following details

```yaml
---
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: loki-bucket
  namespace: rook-ceph
spec:
  generateBucketName: loki-bucket
  storageClassName: rook-ceph-bucket
```

Get the details for the bucket


```bash
./hacks/get-bucket-details.sh
```

## Cleaning up

List current PV csi images in use

```bash
kubectl get pv | grep rook-ceph-block | awk '{print $1}' | xargs -I % bash -c "kubectl get pv -o jsonpath='{.spec.csi.volumeAttributes.imageName}{\"\n\"}' %"
```

Use the `rook-ceph-tools` pod to list all current rados block devices

```bash
rbd list --pool replicapool
```

Get a list of rados block devices to remove and run

```bash
rbd trash mv -p replicapool <rados block device>
```

Double check the list

```bash
rbd trash ls replicapool
```

Purge trash to free space
```bash
rbd trash purge replicapool
```

When purgeing only those images that expired as specified in the purgeing schedule
`rbd trash purge schedule list replicapool` will be deleted.
