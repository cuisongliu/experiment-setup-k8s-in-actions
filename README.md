
## Intro

We need to create a temporary kubernetes cluster in github actions for running e2e tests in actions.

- sealos run k8s in github actions

## Usage

See [action.yml](action.yml)

**Sealos**:
```yaml
steps:
- name: Auto install k8s using sealos
  uses: cuisongliu/experiment-setup-k8s-in-actions@v0.0.1-rc1
  with:
    rootfsImage: labring/kubernetes:v1.24.0
    sealosVersion: 4.1.3
    useBuildah: false
    debug: true
- name: Run app image
  run:  sealos run labring/helm:v3.8.2 labring/calico:v3.24.1 -f --debug
```

## Installers comparison

sealos:  Supports `cluster image`, it is very convenient to install helm, ingress, cert-manager, @see https://sealos.io
