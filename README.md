## Intro

We need to create a temporary kubernetes cluster in github actions for running e2e tests in actions.

- sealos run k8s in github actions

## Usage

See [action.yml](action.yml)

**Sealos**:

```yaml
steps:
  - name: Auto install sealos
    uses: labring/sealos-action@v0.0.2-rc1
    with:
      sealosVersion: 4.1.3
      buildah: false
      debug: true
      sealctl: true
  - name: Sealos version
    uses: labring/sealos-action@v0.0.2-rc1
    with:
      type: version
  - name: Login sealos
    uses: labring/sealos-action@v0.0.2-rc1
    with:
      type: login
      username: labring
      password: ${{ secrets.REGISTRY }}
      registry: docker.io
  - name: Build sealos image by dockerfile
    uses: labring/sealos-action@v0.0.2-rc1
    with:
      type: build
      image: ghcr.io/${{ github.repository_owner }}/testactionimage:dockerfile
      debug: true
      working-directory: test/build-dockerfile
  - name: Build sealos image by kubefile
    uses: labring/sealos-action@v0.0.2-rc1
    with:
      type: build
      image: ghcr.io/${{ github.repository_owner }}/testactionimage:kubefile
      debug: true
      working-directory: test/build-kubefile
  - name: Push sealos image
    uses: labring/sealos-action@v0.0.2-rc1
    with:
      type: push
      image: ghcr.io/${{ github.repository_owner }}/testactionimage:dockerfile
      debug: true
  - name: Run images
    uses: labring/sealos-action@v0.0.2-rc1
    with:
      type: images
      debug: true
  - name: Auto install k8s using sealos
    uses: labring/sealos-action@v0.0.2-rc3
    with:
      image: labring/kubernetes:v1.24.0
      debug: true
      type: run

```

| Name | Description                              | Default                      |
| --- |------------------------------------------|------------------------------|
| `image` | kubernetes rootfs image                  | `labring/kubernetes:v1.24.0` |
| `sealosVersion` | sealos version                           | `4.1.3`                      |
| `buildah` | install buildah to /usr/bin              | `false`                      |
| `debug` | debug mode                               | `false`                      |
| `sealctl` | install sealctl  to /usr/bin             | `false`                      | 

## Installers comparison

sealos:  Supports `cluster image`, it is very convenient to install helm, ingress, cert-manager, @see https://sealos.io

## ChangeLog

### v0.0.1

1. support sealos run k8s and app in action
2. support install buildah param

### 0.0.2
1. support working-directory
2. support sealctl
3. support debug mode
4. support install/build/run-k8s/run-app/login/push/version/images

## Feature

1. support sealos,sealctl (url,file,oci),not release version
