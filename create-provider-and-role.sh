#!/bin/bash

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp \
&& sudo mv /tmp/eksctl /usr/local/bin \
&& eksctl version

eksctl utils associate-iam-oidc-provider --cluster $1 --approve
eksctl create iamserviceaccount --cluster=$1 --namespace=kube-system --name=cluster-autoscaler \
--attach-policy-arn=$2 --override-existing-serviceaccounts --approve