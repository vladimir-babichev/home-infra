ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
APP_NAME := unifi
CHART := k8s-at-home/unifi

.PHONY: repo
repo:
	helm repo add k8s-at-home https://k8s-at-home.com/charts/
	helm repo update

.PHONY: pull
pull:
	helm pull --untar $(CHART)

.PHONY: deploy
deploy:
	kubens home-services
	helm upgrade -i -f values.yaml $(APP_NAME) $(CHART)
