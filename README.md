# gitops-argocd

## Applications

### core

* [x] [Argo CD](https://argo-cd.readthedocs.io/en/stable/x)
* [ ] [cert-manager](https://cert-manager.io/)
* [ ] [descheduler]
* [ ] [external-secrets](https://github.com/external-secrets/external-secrets)
* [ ] [Hashicorp Vault]
* [ ] [hajimari](https://github.com/toboshii/hajimari)
* [ ] [kured]
* [ ] [metallb]
* [ ] [node-feature-discovery]
* [ ] [node-problem-detector]
* [ ] [reloader](https://github.com/stakater/Reloader)
* [ ] [velero]
* [ ] [nfs-subdir-external-provisioner]
* [ ] [intel-gpu_plugin]

### ingress-internal

* [ ] [Traefik](https://doc.traefik.io/traefik/)

### ingress-external

* [ ] [Traefik Forward Auth](https://github.com/thomseddon/traefik-forward-auth)
* [ ] [Traefik](https://doc.traefik.io/traefik/)

### services

* [ ] [GitLab](https://about.gitlab.com/)
* [ ] [MySQL](https://www.mysql.com/)
* [ ] [Pi-hole](https://pi-hole.net/)
* [ ] [unifi](https://github.com/jacobalberty/unifi-docker)

### system-upgrade

* [ ] [system-upgrade-controller](https://github.com/rancher/system-upgrade-controller)

### home-automation

* [ ] [Frigate](https://frigate.video/)
* [ ] [Home Assistant](https://www.home-assistant.io/)
* [ ] [Mosquitto](https://mosquitto.org/)
* [ ] [Node-RED](https://nodered.org/)
* [ ] [Zwavejs2Mqtt](https://github.com/zwave-js/zwavejs2mqtt)

### TODO

* Integrate with Auth0
* FusionAuth

## Contributing

This project utilises [pre-commit](https://pre-commit.com/) hooks to lint code changes and [Renovate](https://github.com/apps/renovate) app for dependency tracking.

### Local requirements

* [GNU Make](https://www.gnu.org/software/make/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [pre-commit](https://pre-commit.com/)
* [ShellCheck](https://www.shellcheck.net/)

### Setup

```shell
make setup
```
