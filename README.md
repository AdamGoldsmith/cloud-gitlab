# cloud-gitlab

Deploy GitLab CE into a cloud instance. Uses Jeff Geerling's [gitlab role](<https://galaxy.ansible.com/geerlingguy/gitlab/>) to install gitlab on the target instance.

#### Supported clouds

* Google Cloud Platform (GCP)
  * Ubuntu 16.04
  * CentOS 8 (default)

#### Requirements

* Pre-configured cloud provider credentials. For example, with GCP a service account JSON file
* SSH key pair for connecting to newly-created instance
* Ansible (tested with 2.9.4)

#### Getting the code

```
git clone https://github.com/AdamGoldsmith/cloud-gitlab.git --recurse-submodules
```

#### Running the deployment

1. To deploy GitLab into GCP
```
ansible-playbook playbooks/site.yml --extra-vars cloud_provider=gcp
```
__Note:__ Technically the `--extra-vars` is not needed above as the default cloud is GCP.

2. To destroy GCP GitLab deployment
```
ansible-playbook playbooks/site.yml --extra-vars cloud_provider=gcp --tags delete
```

