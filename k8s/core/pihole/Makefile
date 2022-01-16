ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
#APP_NAME := $(shell echo $(ROOT_DIR) | sed 's|.*/||; s|.*\(prometheus-operator\)|\1|')
APP_NAME := pihole

.PHONY: repo
repo:
	helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
	helm repo update

.PHONY: pull
pull:
	helm pull --untar mojo2600/pihole

.PHONY: deploy
deploy:
	kubens default
	helm upgrade -i -f values.yaml $(APP_NAME) mojo2600/pihole

# .PHONY: deploy
# deploy:
# 	kubens default
# 	helm upgrade -i -f values.yaml $(APP_NAME) pihole/
