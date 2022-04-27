1. For LXD deployments, might need to increase the default storage allocation for containers
    ```bash
    lxc storage edit default
    ```
    *Note:* Didn't look to have worked, so tried

    ```bash
    lxc profile edit default
    ```
    added, `size: 20GiB` to `root:` device

2. Until I can properly fix TLS ca-cert from docker-in-docker, the following needs to be configured in the pipeline when communicating to the GitLab docker registry

    ```yaml
    stages:
      - build

    docker_build:
      stage: build
      variables:
        DOCKER_IMAGE: docker:20.10.14
        DOCKER_TLS_CERTDIR: "/certs"
      image: ${DOCKER_IMAGE}
      services:
        - name: ${DOCKER_IMAGE}-dind
          entrypoint: ["dockerd-entrypoint.sh"]
          command: ["--insecure-registry", "gitlab-01:5050"]
      before_script:
        - docker info
      script:
        - echo DOCKER_IMAGE ${DOCKER_IMAGE}
        - echo CI_REGISTRY_IMAGE ${CI_REGISTRY_IMAGE}
        - echo CI_REGISTRY_USER ${CI_REGISTRY_USER}
        - echo ${CI_REGISTRY_PASSWORD} | docker login -u ${CI_REGISTRY_USER} ${CI_REGISTRY} --password-stdin
        - docker build -t ${CI_REGISTRY_IMAGE} .
        - docker push ${CI_REGISTRY_IMAGE}
    ```

    or alternatively store the contents of the GitLab instance's ca-cert file in a variable called CA-CERTIFICATE:

    ```yaml
    stages:
      - build

    docker_build:
      stage: build
      variables:
        DOCKER_IMAGE: docker:20.10.14
        DOCKER_TLS_CERTDIR: "/certs"
        CA_CERTIFICATE: "${CA_CERTIFICATE}"
    image: ${DOCKER_IMAGE}
    services:
      - name: ${DOCKER_IMAGE}-dind
        command:
          - /bin/sh
          - -c
          - echo "${CA_CERTIFICATE}" > /usr/local/share/ca-certificates/my-ca.crt && update-ca-certificates && dockerd-entrypoint.sh || exit
    before_script:
      - docker info
    script:
      - echo DOCKER_IMAGE ${DOCKER_IMAGE}
      - echo CI_REGISTRY_IMAGE ${CI_REGISTRY_IMAGE}
      - echo CI_REGISTRY_USER ${CI_REGISTRY_USER}
      - echo ${CI_REGISTRY_PASSWORD} | docker login -u ${CI_REGISTRY_USER} ${CI_REGISTRY} --password-stdin
      - docker build -t ${CI_REGISTRY_IMAGE} .
      - docker push ${CI_REGISTRY_IMAGE}
