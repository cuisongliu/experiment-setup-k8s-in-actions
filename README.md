
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
```

## Installers comparison

- sealos: 
  - Helm is not built in
  - Supports `cluster image`, it is very convenient to install helm, ingress, cert-manager, @see https://sealos.io
  - Containerd is used, and a dedicated version of the image is required to support docker, and docker will not be installed automatically
  - Large memory usage: 1750M - 500M = 1250M
  - Slower: 2m40s

- k3s
  - Built-in helm
  - High speed: <1m
  - Small memory footprint: 1200M - 500M = 700M 

- kubekey
  - Need to manually install socat, conntrack, ebtables, ipset and other dependencies
  - Built-in helm
  - Friendly support for docker, automatic installation of docker
  - Slower: 2m20s
  - Small memory footprint: 1350M - 500M = 850M
