#!/bin/bash

curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl \
&& chmod +x ./kubectl \
&& mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin \
&& kubectl version --short --client && rm kubectl

aws eks update-kubeconfig --region {{$1}} --name {{$2}} \
&& git clone https://github.com/mayankkthr/k8s-ingress.git \
&& kubectl apply -f k8s-ingress/ns-and-sa.yaml \
&& kubectl apply -f k8s-ingress/default-server-secret.yaml \
&& kubectl apply -f k8s-ingress/nginx-config.yaml \
&& kubectl apply -f k8s-ingress/rbac.yaml \
&& kubectl apply -f k8s-ingress/ingress-class.yaml \
&& kubectl apply -f k8s-ingress/nginx-ingress.yaml \
&& kubectl apply -f k8s-ingress/loadbalancer-aws-elb.yaml \
&& kubectl apply -f k8s-ingress/nginx-config-modified.yaml \
&& kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml \
&& kubectl annotate serviceaccount cluster-autoscaler -n kube-system eks.amazonaws.com/role-arn={{$3}} \
&& kubectl patch deployment cluster-autoscaler -n kube-system -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}' \
#rm -rf k8s-ingress/ \
#&& kubectl apply -f aws-auth-cm.yaml \
&& kubectl set image deployment cluster-autoscaler -n kube-system cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0 \
&& kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml