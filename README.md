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
* [ ] [system-upgrade-controller](https://github.com/rancher/system-upgrade-controller)
* [ ] [velero]
* [ ] [nfs-subdir-external-provisioner]
* [ ] [intel-gpu_plugin]

### ingress-internal

* [traefik](https://doc.traefik.io/traefik/)

### ingress-external

* [traefik](https://doc.traefik.io/traefik/)
* [traefik-forward-auth](https://github.com/thomseddon/traefik-forward-auth)

### services

* [mysql]
* [gitlab]
* unifi

### Home Automation

* frigate
* home-assistant
* mosquitto
* node-red
* pihole
* zwavejs2mqtt

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
