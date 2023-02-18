## Intro

We need to create a temporary kubernetes cluster in github actions for running e2e tests in actions.

- setup sealos in github actions

## Usage

See [action.yml](action.yml)

**SealosByRelease**:

```yaml
steps:
  - name: Auto install sealos
    uses: labring/sealos-action@v0.0.3
    with:
      sealosVersion: 4.1.3

  - name: Sealos version
    run: sudo sealos version

  - name: Login sealos
    run: |
      sudo sealos login -u ${{ github.repository_owner }} -p ${{ secrets.GH_TOKEN }} --debug ghcr.io

  - name: Build sealos image by dockerfile
    working-directory: test/build-dockerfile
    run: |
      sudo sealos build -t testactionimage:dockerfile -f Dockerfile .

  - name: Build sealos image by kubefile
    working-directory: test/build-kubefile
    run: |
      sudo sealos build -t testactionimage:kubefile -f Kubefile .

  - name: Run images
    run: |
      sudo sealos images
  - name: Auto install k8s using sealos
    run: |
      sudo sealos run  labring/kubernetes:v1.24.0 --single

```

**SealosByMainCode**:

```yaml
steps:
  - name: Auto install sealos
    uses: labring/sealos-action@v0.0.3
    with:
      type: install-dev
      sealosGit: https://github.com/cuisongliu/sealos.git
      sealosGitBranch: main
      goAddr: https://go.dev/dl/go1.20.linux-amd64.tar.gz
      pruneCRI: true

  - name: Sealos version
    run: sudo sealos version

  - name: Login sealos
    run: |
      sudo sealos login -u ${{ github.repository_owner }} -p ${{ secrets.GH_TOKEN }} --debug ghcr.io

  - name: Build sealos image by dockerfile
    working-directory: test/build-dockerfile
    run: |
      sudo sealos build -t testactionimage:dockerfile -f Dockerfile .

  - name: Build sealos image by kubefile
    working-directory: test/build-kubefile
    run: |
      sudo sealos build -t testactionimage:kubefile -f Kubefile .

  - name: Run images
    run: |
      sudo sealos images
  - name: Auto install k8s using sealos
    run: |
      sudo sealos run  labring/kubernetes:v1.24.0 --single

```

| Name                | Description                                  | Default                                       |
|---------------------|----------------------------------------------|-----------------------------------------------|
| `type`              | sealos action type, 'install/install-dev/prune'   | `install`                                     |
| `sealosVersion`     | sealos version                               | `4.1.3`                                       |
| `working-directory` | working directory for build image            | ``                                            |
| `sealosGit`         | sealos git addr, using type=install-dev      | `https://github.com/labring/sealos.git`       |
| `sealosGitBranch`   | sealos git branch, using type=install-dev    | `main`                                        |
| `pruneCRI`          | pruneCRI pkg ex: docker,runc,containerd      | `true`                                        |
| `autoFetch`         | auto fetch git code                          | `true`                                        |
| `goAddr`            | go tar download addr, using type=install-dev | `https://go.dev/dl/go1.20.linux-amd64.tar.gz` |

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

### 0.0.3

1. support main sealos build
2. delete build/run-k8s/run-app/login/push/version/images
3. support install-dev

### 0.0.4

1. support git branch
2. support prune cri pkg

### 0.0.5

1. support autoFetch

### 0.0.6

1. support arm64

### 0.0.7

1. add prune


## Test

[Action](https://github.com/labring/cluster-image/blob/main/.github/workflows/autobuild-testsealos.yml)

[Running](https://github.com/labring/cluster-image/actions/runs/3361452446)


