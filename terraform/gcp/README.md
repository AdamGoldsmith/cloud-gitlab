## Terraform for GCP configuration

This repo is designed to call the necessary underlying infrastructure management via Ansible's [`terraform` module](https://docs.ansible.com/ansible/latest/modules/terraform_module.html), calling isolated terraform directories for each component. These directories use their own remote state file stored in a single cloud storage bucket. There are many reasons why you should use a remote state file with Terraform, mainly sharing between project collaborators, file locking and avoiding secret spillage. This repo uses Ansible to create the remote storage bucket via native Ansible modules which removes the "chicken & egg" state file dilemma that is presented when using Terraform to initially create this bucket. Furthermore, once this bucket is created via Ansible, all subsequent calls from Ansible using the `terraform` module can utilise the same backend configuration.

### How it works

The backend storage and remote state file configuration has been designed to minimise user input. Here are the steps that are performed when Ansible is executed:

1. Ansible creates a GCP Cloud Bucket using the `gcp_storage_bucket` module in the playbook called [`base_create.yml`](cloud-gitlab\playbooks\base\base_create.yml). The bucket name has to be globally unique so it uses a combination of the project id suffixed with `-tfstate`. Versioning is enabled for history tracking of the state file.
2. Now every time Ansible uses the `terraform` module, the `backend_config` arguments are passed to terraform for referencing the correct remote state file relevant to the infrastructure being addressed.

For example, when deploying infrastructure related to GitLab, the following would be applicable:

```yaml
- name: Deploy bastion cloud configuration resources
  vars:
    service_name: gitlab
    tf_vars:
      service_name: "{{ service_name }}"
      cred_file: "{{ gcp_data['cred_file'] | expanduser }}"
      project_name: "{{ gcp_data['project'] }}"
      region_name: "{{ project_region }}"
      network_name: "{{ project_data['network']['name'] }}"
    tf_instance_vars: "{{ project_data['services'][service_name] }}"
  terraform:
    project_path: "{{ inventory_dir |
      default(ansible_inventory_sources[0])
      }}/../terraform/{{ cloud_provider }}/{{ service_name }}"
    state: present
    force_init: yes
    lock: yes
    variables: "{{ tf_vars | combine(tf_instance_vars) }}"
    backend_config: "{{ tf_backend_config }}"
```

Note that `backend_config` is defined in `host_vars/localhost` as:
```yaml
tf_backend_config:
  credentials: "{{ gcp_data['cred_file'] | expanduser }}"
  bucket: "{{ gcp_data['project'] }}-tfstate"
  # Best not to default this and risk using an undesirable remote state file!
  prefix: "{{ service_name }}"
```
The `prefix` is the directory in the bucket where the remote state file resides. So, if the project ID was `inspired-access-273514`, the resulting bucket & remote state file would be named as follows:

| Bucket name | State file name |
|-------------|-----------------|
|inspired-access-273514-tfstate|gitlab/default.tfstate|
