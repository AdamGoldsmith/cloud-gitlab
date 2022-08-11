1. For LXD deployments, might need to increase the default storage allocation for containers
    ```bash
    lxc storage edit default
    ```
    *Note:* Didn't look to have worked, so tried

    ```bash
    lxc profile edit default
    ```
    added, `size: 20GiB` to `root:` device

1. Running Centos 7 in LXD >5.0 requires a [kernel tweak](https://discuss.linuxcontainers.org/t/error-the-image-used-by-this-instance-requires-a-cgroupv1-host-system-when-using-clustering/13885) on the host
    ```
    grep GRUB_CMDLINE_LINUX= /etc/default/grub

    GRUB_CMDLINE_LINUX=""
    ```

    ```
    sudo sed -i -e 's/^GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=0"/' /etc/default/grub
    ```

    ```
    grep GRUB_CMDLINE_LINUX= /etc/default/grub

    GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=0"
    ```

    ```
    sudo update-grub
    ```

1. Until I can properly fix TLS ca-cert from docker-in-docker, the following needs to be configured in the pipeline when communicating to the GitLab docker registry

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
