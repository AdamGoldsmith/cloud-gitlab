## Terraform for GCP configuration

This repo is designed to call the necessary underlying infrastructure management via Ansible's [`terraform` module](https://docs.ansible.com/ansible/latest/modules/terraform_module.html), calling isolated terraform directories for each component. These directories use their own remote state file stored in a single cloud storage bucket. There are many reasons why you should use a remote state file with Terraform, mainly sharing between project collaborators, file locking and avoiding secret spillage. This repo uses Ansible to create the remote storage bucket via native Ansible modules which removes the "chicken & egg" state file dilemma that is presented when using Terraform to initially create this bucket. Furthermore, once this bucket is created via Ansible, all subsequent calls from Ansible using the `terraform` module can utilise the same backend configuration.

### How it works

The backend storage and remote state file configuration has been designed to minimise user input. Here are the steps that are performed when Ansible is executed:

1. Ansible creates a GCP Cloud Bucket using the `gcp_storage_bucket` module in the playbook called [`base_create.yml`](cloud-gitlab\playbooks\base\base_create.yml). The bucket name has to be globally unique so it uses a combination of the project id suffixed with `-tfstate`. Versioning is enabled for history tracking of the state file.
2. Now every time Ansible uses the `terraform` module, the `backend_config` arguments are passed to terraform for referencing the correct remote state file relevant to the infrastructure being addressed.

For example, when deploying infrastructure related to GitLab, the following would be applicable:

```yaml
- name: Deploy GitLab cloud configuration resources
  vars:
    service_name: gitlab
    tf_vars:
      service_name: "{{ service_name }}"
      region_name: "{{ project_region }}"
      network_name: "{{ project_data['network']['name'] }}"
    tf_vars_all: "{{ tf_cred_data[cloud_provider] |
      combine(tf_vars) |
      combine(project_data['services'][service_name]) }}"
  terraform:
    project_path: "{{ inventory_dir |
      default(ansible_inventory_sources[0])
      }}/../terraform/{{ cloud_provider }}/{{ service_name }}"
    state: present
    force_init: yes
    lock: yes
    variables: "{{ tf_vars_all }}"
    backend_config: "{{ tf_backend_config[cloud_provider] }}"
  register: tf_outputs
```
>__NOTE:__ At the time of writing, there is a [known issue](https://github.com/ansible/ansible/issues/51687) with passing dict/list variables to terraform via the `variables` parameter. This repo uses a workaround where it writes the terraform variables to a temporary JSON file, then uses this file when invoking terraform module. This workaround is not necessary demonstrating the backend config so it is not illustrated above.

Note that `backend_config` is defined in `host_vars/localhost/cloud.yml` as:
```yaml
tf_backend_config:
  gcp:
    credentials: "{{ cred_data[cloud_provider]['cred_file'] | expanduser }}"
    bucket: "{{ cred_data[cloud_provider]['project_name'] }}-tfstate"
    # Best not to default this and risk using an undesirable remote state file!
    prefix: "{{ service_name }}"
```
The `prefix` is the directory in the bucket where the remote state file resides. So, if the project ID was `inspired-access-273514`, the resulting bucket & remote state file would be named as follows:

| Bucket name | State file name |
|-------------|-----------------|
|inspired-access-273514-tfstate|gitlab/default.tfstate|
