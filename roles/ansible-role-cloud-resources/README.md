# ansible-role-cloud-resources

Deploys cloud resources and services on various cloud providers defined by supplied data variables.

## Supported Cloud Providers

* GCP

## GCP actions

Actions are based on a supplied "services" structure defined in a `project_data` dictionary. If correct credentials are supplied, by default the following actions will be performed (see default [role variables](#role-variables) section):

* Create "base" service resources:
    * Create VPC network
    * Create external address
    * Create common firewall rules
* Create "bastion" service resources:
    * Create VPC network
    * Create external address dedicated to bastion instance
    * Create bastion instance boot disk
    * Create bastion instance

Currently tested on these Operating Systems
* CentOS 8

## Requirements

* Ansible 2.5 or higher

## Role Variables

defaults/main.yml
```yaml
---

cloud_provider: gcp                                                             # Defaults to GCP cloud provider
resource_action: create                                                         # Default action is to create resources

# GCP defaults
gcp_data:                                                                       # Generic GCP credentials dictionary
  cred_file: ~/gcp/project-creds.json                                           # Path to downloaded JSON credentials file
  project: project-access-123456                                                # Project ID
  cred_kind: serviceaccount                                                     # Type of access
  ssh_user: ansible                                                             # User Ansible will connect as to the Compute VMs
  ssh_pubkey: ~/gcp/id_rsa.pub                                                  # Path to public key used to connect with instances
service_name: base                                                              # Service name to process in project_data dictionary
project_region: europe-west2                                                    # Region of project deployment
project_data:                                                                   # Data dictionary containing all project resource defninitions
  # Base network configuration for the project
  network:                                                                      # VPC network resource dictionary
    name: project                                                               # VPC network name (appended with "-network")
    region: "{{ project_region }}"                                              # VPC network's region
  services:                                                                     # Services resource dictionary
    # No instances but a generic ext address & fw rules
    base:                                                                       # "base" service resource dictionary used to create an external address and common firewall rules
      ext_addresses:                                                            # External address resource list of dictionaries
        - name: 1                                                               # External address name (converted to "<service>-<name>-address", eg "`base-1-address`")
      scopes:                                                                   # API scopes
        - https://www.googleapis.com/auth/compute
      fw_data:                                                                  # Firewall rules list of dictionaries
        - name: allow-internal                                                  # Firewall rule name (converted to "<service>-<name>-fw", eg "`base-1-fw`")
          description: Allow all UDP/TCP ports internally                       # Firewall rule description
          allowed:                                                              # List of "allowed" firewall rules in dictionary definitions
            - ip_protocol: tcp                                                  # Allowed protocols (tcp, udp, icmp, esp, ah, sctp)
              ports:                                                            # Optional list of allowed ports
                - '0-65535'                                                     # Examples include `["22"]`, `["80","443"]`, and `["12345-12349"]`
            - ip_protocol: udp
              ports:
                - '0-65535'
            - ip_protocol: icmp
          source_ranges:                                                        # Optional list that the firewall will apply only to traffic
            - '10.128.0.0/9'                                                    # that has source IP address in these ranges
          pri: 65534                                                            # Priority of rule, lowest is preferenced (0-65534)
        - name: allow-icmp
          description: Allow ICMP externally
          allowed:
            - ip_protocol: icmp
          pri: 65534
        - name: allow-ssh
          description: Allow SSH externally
          allowed:
            - ip_protocol: tcp
              ports:
                - '22'
          pri: 65534
    # Bastion SSH proxy service
    bastion:                                                                    # "bastion" service resource dictionary
      instances:                                                                # List of instance dictionaries
        - name: 1                                                               # Name of instance (converted to "<service>-<name>-vm", eg "`bastion-1-vm`")
          disk:                                                                 # Boot disk data dictionary
            size_gb: 20                                                         # Size of disk to create (minimum 20)"
            source_image: projects/centos-cloud/global/images/family/centos-8   # Image to use for boot disk
          machine_type: f1-micro                                                # VM's machine type
          zone: "{{ project_region }}-a"                                        # Zone in which to create the instance
          create_external_ip: yes                                               # Boolean to create and attach a dedicated external address
      scopes:
        - https://www.googleapis.com/auth/compute
```

As described above, the default `project_data` configuration will deploy a base project with a project-wide VPC network, an external IP address for accessing services via port-forwarding rules, and a bastion SSH instance with a dedicated external address for managing internal, non internet-facing instances. If you now wanted to add a new instance that will be hosting a web service on port 80, you could run this role with the following components added to the `project_data['services']` dictionary:

```yaml
    web:                                                                        # "web" service resource dictionary
      instances:                                                                # List of instance dictionaries
        - name: 1                                                               # Name of instance (converted to "<service>-<name>-vm", eg "`web-1-vm`")
          disk:                                                                 # Boot disk data dictionary
            size_gb: 20                                                         # Size of disk to create (minimum 20)"
            source_image: projects/centos-cloud/global/images/family/centos-8   # Image to use for boot disk
          machine_type: n1-standard-1                                           # VM's machine type
          zone: "{{ project_region }}-a"                                        # Zone in which to create the instance
          create_external_ip: no                                                # Do not create an associated external address
      target_pool_data:                                                         # List of target pool dictionaries for accessing internally-hosted services from the internet
        - name: 1                                                               # Name of target pool (converted to "<service>-<name>-target-pool", eg "`web-1-target-pool`")
          ip_protocol: TCP                                                      # IP protocol to which this rule applies (TCP, UDP, ESP, AH, SCTP or ICMP)
          port_range: 80-80                                                     # Only packets addressed to ports in the specified range will be forwarded to target
          address:                                                              # Dictionary of data related to the associated source external address
            service: base                                                       # Name of service used to create the external address (eg `base`)
            name: 1                                                             # Name of the service's address resource (eg `base-1-address`)
      scopes:
        - https://www.googleapis.com/auth/compute
      fw_data:
        - name: allow-gitlab
          description: GitLab service port
          allowed:
            - ip_protocol: tcp
              ports:
                - '80'
          pri: 65500
```

## Inventory

Instances are created with a label key called `ansible_group` which takes the service name as a value. It is recommended to use a mixture of static and dynamic inventory sources. See [here](https://docs.ansible.com/ansible/latest/scenario_guides/guide_gce.html#gce-dynamic-inventory) and [here](https://www.diewufeiyang.com/ansible/en/plugins/inventory/gcp_compute.html) for enabling & further configuration of GCP dynamic inventory.

By adding the following lines to the dynamic inventory YAML file, you will be able to access instances created by this role via the service name.

`<inventory_dir>/inventory.gcp.yml`
```yaml
keyed_groups:
  - prefix: gcp
    key: labels
```

Continuing to use the "web" service as an example, any instance created under the "web" service will allow Ansible to reference them by a group named `gcp_ansible_group_web`, which can easily be added to your inventory file as shown:

`<inventory_dir>/inventory`
```ini
[gcp_ansible_group_web]
```

To make things easier to reference, add the shorter-named group `web` into the inventory file with `gcp_ansible_group_web` defined as children as shown here:

`<inventory_dir>/inventory`
```ini
[web:children]
gcp_ansible_group_web
```

## Bastion SSH Proxy

It is recommended to set up the Ansible controller's inventory vars to allow connectivity to internal instances via the bastion SSH proxy instance by configuring the following inventory variables.

First add the "bastion" groups:

`<inventory_dir>/inventory`
```ini
[gcp_ansible_group_bastion]

[bastion:children]
gcp_ansible_group_bastion
```

Then add the "web" group as a child group to the "sshproxy" group:

`<inventory_dir>/inventory`
```ini
[sshproxy:children]
web
```

Now add the following lines to the "sshproxy" group vars file:

`<inventory_dir>/group_vars/sshproxy/vars.yml`
```yaml
---

ssh_args: '-o ProxyCommand="ssh
  -o UserKnownHostsFile=/dev/null
  -o StrictHostKeyChecking=no
  -o IdentityFile={{ ansible_ssh_private_key_file }}
  -W %h:%p -q {{ ansible_user }}@{{ groups.bastion[0] }}"'
# Apply proxy ssh arguments when remote host has no public IP address
ansible_ssh_common_args: "{{ inventory_hostname | ipaddr('private') | ternary(ssh_args, '') }}"
ansible_port: 22
```

This will use the first host in the "bastion" group as the SSH proxy to any instances belonging to the "sshproxy" group, which is "web" in the case of this example. If there is no external address associtated with the instance, the SSH proxy arguments `ssh_args` are applied, otherwise a direct connection will be made.

## Dependencies

None

## Example Playbook

Create default GCP cloud resources

```yaml
---

- name: Cloud provider Web deployment
  hosts: localhost
  connection: local
  gather_facts: no
  tags:
    - create
    - web
    - web_create

  tasks:

    - name: Deploy web cloud instances
      vars:
        service_name: web
        resource_action: create
      include_role:
        name: ansible-role-cloud-resources

  post_tasks:

    - name: Refresh inventory to ensure new instances exist in inventory
      meta: refresh_inventory
```

Destroy default GCP cloud resources

```yaml
---

- name: Cloud provider Web destruction
  hosts: localhost
  connection: local
  gather_facts: no
  tags:
    - destroy
    - web
    - web_destroy

  tasks:

    - name: Destroy web cloud instances
      vars:
        service_name: web
        resource_action: destroy
      include_role:
        name: ansible-role-cloud-resources
```

## License

MIT License

## Author Information

Adam Goldsmith
