#!/bin/bash

VALUE_1=$(printf '%s\n' "$1" | sed -e 's/[\/&]/\\&/g')
VALUE_2=$(printf '%s\n' "$2" | sed -e 's/[\/&]/\\&/g')
VALUE_3=$(printf '%s\n' "$3" | sed -e 's/[\/&]/\\&/g')
VALUE_4=$(printf '%s\n' "$4" | sed -e 's/[\/&]/\\&/g')
VALUE_5=$(printf '%s\n' "$5" | sed -e 's/[\/&]/\\&/g')
VALUE_6=$(printf '%s\n' "$6" | sed -e 's/[\/&]/\\&/g')

curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl \
&& chmod +x ./kubectl \
&& mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin \
&& kubectl version --short --client && rm kubectl

aws eks update-kubeconfig --region $AWS_REGION --name $VALUE_1 \
&& git clone https://github.com/rocketmlhq/k8s-ingress.git

sed -i "s/ClusterNameValue/$VALUE_1/" k8s-ingress/cluster-autoscaler.yaml
sed -i "s/value1/$VALUE_2/" k8s-ingress/aws-auth-cm.yaml
sed -i "s/value2/$VALUE_3/" k8s-ingress/aws-auth-cm.yaml
sed -i "s/value3/$VALUE_4/" k8s-ingress/aws-auth-cm.yaml
sed -i "s/value4/$VALUE_5/" k8s-ingress/aws-auth-cm.yaml
sed -i "s/value/$VALUE_6/" k8s-ingress/loadbalancer-aws-elb.yaml

kubectl apply -f k8s-ingress/aws-auth-cm.yaml \
&& kubectl apply -f k8s-ingress/ns-and-sa.yaml \
&& kubectl apply -f k8s-ingress/default-server-secret.yaml \
&& kubectl apply -f k8s-ingress/nginx-config.yaml \
&& kubectl apply -f k8s-ingress/rbac.yaml \
&& kubectl apply -f k8s-ingress/ingress-class.yaml \
&& kubectl apply -f k8s-ingress/nginx-ingress.yaml \
&& kubectl apply -f k8s-ingress/loadbalancer-aws-elb.yaml \
&& kubectl apply -f k8s-ingress/nginx-config-modified.yaml \
&& kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml \
&& kubectl patch deployment cluster-autoscaler -n kube-system -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}' \
&& kubectl set image deployment cluster-autoscaler -n kube-system cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0 \
&& kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml \
&& kubectl apply -f k8s-ingress/cluster-autoscaler.yaml

rm -rf k8s-ingress/