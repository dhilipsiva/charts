#! /bin/bash
#
# recreate_deis.sh
# Copyright (C) 2016 dhilipsiva <dhilipsiva@gmail.com>
#
# Distributed under terms of the MIT license.
#

CLUSTER_NAME=one
DEIS_VERSION=2.1.0
NODE_TYPE=n1-standard-2
# gcloud compute disks delete --zone=us-central1-a data-pg
# gcloud compute disks delete --zone=us-central1-a data-rabbit
gcloud compute disks create --size=300GB --type=pd-ssd --zone=us-central1-a data-pg
gcloud compute disks create --size=10GB --type=pd-ssd --zone=us-central1-a data-rabbit
gcloud container clusters delete $CLUSTER_NAME
gcloud container clusters create --machine-type=$NODE_TYPE $CLUSTER_NAME
helmc target
helmc repo add deis https://github.com/deis/charts
helmc up
helmc fetch deis/workflow-v$DEIS_VERSION
helmc generate -f -x manifests workflow-v$DEIS_VERSION
helmc install workflow-v$DEIS_VERSION
kubectl --namespace=deis get pods -w
kubectl --namespace=deis get pods
kubectl --namespace=deis describe service deis-router | grep "LoadBalancer Ingress"
echo "now, run this:"
echo "deis register http://deis.ROUTER_IP.nip.io"
