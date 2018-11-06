#!/usr/bin/env bash
set -xe
kubectl apply -f kubernetes-glcoud/mysql.yml
kubectl apply -f kubernetes-glcoud/web.yml
