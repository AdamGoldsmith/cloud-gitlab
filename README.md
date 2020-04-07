# cloud-gitlab

Deploy GitLab CE into a cloud instance

#### Supported clouds

* Google Cloud Platform (GCP)

#### Example playbook execution

1. To deploy GitLab into GCP
```
ansible-playbook playbooks/site.yml --extra-vars cloud_provider=gcp
```

2. To destroy GCP GitLab deployment
```
ansible-playbook playbooks/site.yml --extra-vars cloud_provider=gcp --tags delete
```

