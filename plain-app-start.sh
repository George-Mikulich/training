#!/bin/bash
# This script installs argocd and deploys simple guestbook app

set -e

minikube start
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
brew install argocd
argocd login --core
kubectl config set-context --current --namespace=argocd

for (( ; ; ))
do
        echo "waiting for pods to be ready"
        sleep 1
        allPods=$(kubectl get pods --no-headers | wc -l)
        runningPods=$(kubectl get pods --no-headers | grep -P "(\d+)\/\1\s+Running" | wc -l)
        if [ $allPods == $runningPods ]
        then
                echo "all pods are ready"
                break
        fi
done

argocd app create guestbook --repo https://github.com/George-Mikulich/training --revision first-app-plain --path guestbook-app --dest-server https://kubernetes.default.svc --dest-namespace default
argocd app sync guestbook
minikube service guestbook-ui --url
