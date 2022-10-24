
## Intro

We need to create a temporary kubernetes cluster in github actions for running e2e tests in actions.

- sealos run k8s in github actions

## Usage

See [action.yml](action.yml)

**Sealos**:
```yaml
steps:
- name: Auto install k8s using sealos
  uses: labring/sealos-action@v0.0.1
  with:
    image: labring/kubernetes:v1.24.0
    sealosVersion: 4.1.3
    buildah: false
    debug: true
- name: Run app image
  run:  sudo sealos run labring/helm:v3.8.2 labring/calico:v3.24.1  --debug
```

## Installers comparison

sealos:  Supports `cluster image`, it is very convenient to install helm, ingress, cert-manager, @see https://sealos.io


## ChangeLog

### v0.0.1

1. support sealos run k8s and app in action
2. support install buildah param

## Feature

1. support sealos,sealctl (url,file,oci),not release version
2. get nodeIP
3. disable k8s
