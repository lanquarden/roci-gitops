#!/usr/bin/env bash

BUCKET=$1

echo "BUCKET_HOST=$(kubectl -n rook-ceph get cm $BUCKET -o jsonpath='{.data.BUCKET_HOST}')"
echo "BUCKET_ENDPOINT=$(kubectl -n rook-ceph get svc rook-ceph-rgw-ceph-object-store -o jsonpath='{.spec.clusterIP}'):$(kubectl -n rook-ceph get svc rook-ceph-rgw-ceph-object-store -o jsonpath='{.spec.ports[0].port}')"
echo "BUCKET_NAME=$(kubectl -n rook-ceph get cm loki-bucket -o jsonpath='{.data.BUCKET_NAME}')"
echo "BUCKET_AWS_ACCESS_KEY_ID=$(kubectl -n rook-ceph get secret loki-bucket -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)"
echo "BUCKET_AWS_SECRET_ACCESS_KEY=$(kubectl -n rook-ceph get secret loki-bucket -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --decode)"
