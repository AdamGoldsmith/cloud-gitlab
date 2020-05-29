# cloud-gitlab

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Deploy GitLab CE & Hashicorp Vault into cloud instances. Uses Jeff Geerling's [gitlab role](<https://galaxy.ansible.com/geerlingguy/gitlab/>) to install gitlab on the target gitlab instance.

The Vault cluster is deployed using updated roles taken from [this repo](https://github.com/AdamGoldsmith/consul-vault). The cluster deployment takes advantage of Vault's integrated storage option released in version 1.4 which makes life a lot less complicated by removing the need to deploy an entire backend Consul configuration.

#### Network Topology

Here is a generalised diagramtic representation of the deployment. Management of internal instances without external-facing addresses, such as gitlab & vault instances, is performed via a bastion instance using [SSH proxy arguments](#SSH-proxy-&-inventories). A single external address with port-forwarding rules defined is used to reach the desired backend GitLab & Vault services.
![Alt text](images/GitLab-Vault-Topology.jpg "Overview of deployment")

#### Supported platforms

| Cloud Provider | Platform |
|----------------|----------|
| Google Cloud Platform | CentOS 8 (default) |
|                       | Ubuntu 16.04 |

#### Requirements

* Pre-configured cloud provider credentials. For example, with GCP a service account JSON file
* SSH key pair for connecting to newly-created instance
* Ansible 2.7+ (tested with 2.9.4)

For further information refer to the [Google Cloud Platform Guide](https://docs.ansible.com/ansible/latest/scenario_guides/guide_gce.html)

#### Python3 virtual environment (recommended)

The steps below illustrate an example setup with a `python3` virtual environment.  There are many ways to achieve this goal but this is a simple method and assumes that you have `python3` installed on your linux environment.

__For GCP__

```
mkdir -p ~/venvs
python3 -m venv ~/venvs/cloud-gitlab_gcp
source ~/venvs/cloud-gitlab_gcp/bin/activate
git clone https://github.com/AdamGoldsmith/cloud-gitlab.git
cd cloud-gitlab
pip install -r ./requirements_gcp.txt
```

#### GCP credentials

You will need valid credentials for GCP to be able to deploy the project.  This is covered in the [Credentials](https://docs.ansible.com/ansible/latest/scenario_guides/guide_gce.html#credentials) section of the Ansible GCP guide.  Assuming that you have created a `Service Account` and have the `.json` file downloaded you can perform the following example steps, pasting in and saving your `Service Account`.`json` contents at the `vi` step:

```
mkdir -p ~/gcp
vi ~/gcp/gitlab-creds.json
chmod 0600 ~/gcp/gitlab-creds.json
```

#### SSH keypair

As mentioned, a keypair is required to connect to the GCP instance. By default the deployment will look in `~/gcp` for the required key.  To create the location and keypair you can work through the following example:

```
cd ~/gcp
ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/tony/.ssh/id_rsa): ./id_rsa
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in ./id_rsa.
Your public key has been saved in ./id_rsa.pub.
The key fingerprint is:
SHA256:1YP0ULXqssHeCO8Yc2sCsOUWAvj6aSfIcVynRRN06nM tony@CPX-ZL3E87HNB8M
The key's randomart image is:
+---[RSA 2048]----+
| .    .o..o....  |
|. .    oo. =   . |
| . .  ... o + .  |
|  . o.+o .   o   |
| .. .*++SE  .    |
|.. o..+ o. .     |
|.oo. . .+ = .    |
|..= .   .O.B     |
| . o    .+B .    |
+----[SHA256]-----+
```

#### Getting the code

```
git clone https://github.com/AdamGoldsmith/cloud-gitlab.git
```

#### SSH proxy & inventories

It is worth noting, I have chosen to connect to cloud-hosts via an SSH proxy (bastion) host to keep management and costs to a minimum.

This Ansible configuration uses a mixture of static & dynamic inventories residing in an inventory directory called `inv.d` (configured in [`ansible.cfg`](ansible.cfg)).

There is a group called `sshproxy` which has an associated [`group_vars/sshproxy/vars.yml`](inv.d/group_vars/sshproxy/vars.yml) file. In this file, if a remote Ansible host is detected on a public IP address, Ansible will attempt to connect directly to the target. However, if the host is detected on a private IP address, Ansible will set SSH Proxy arguments to connect to the target via the first SSH proxy host found in the `bastion` group (this deployment only stands up one bastion instance).

Only hosts/groups in the `sshproxy` group will be affected by this process.

__Note__: To force GCP's dynamic inventory [configuration file](inv.d/inventory.gcp.yml) to return the internal IP addressses of instances, uncomment the following lines:
```yml
# hostnames:
#   - private_ip
```
More information on GCP's dynamic inventory can be found [here](https://www.diewufeiyang.com/ansible/en/plugins/inventory/gcp_compute.html)

#### GCP

##### Inventory

As stated, this configuration uses a mixture of static and dynamic inventory sources. Instances are created with a label key called `ansible_group` which takes the service name as a value. Inspecting the contents of the GCP dynamic inventory [configuration file](cloud-gitlab\inv.d\inventory.gcp.yml) shows the following section:
```yaml
keyed_groups:
  - prefix: gcp
    key: labels
```

This is used to reference the label added at instance creation. For example, adding a label of `vault` to instances will allow Ansible to reference them by a group named `gcp_ansible_group_vault` as can be seen in the [inventory file](inv.d/inventory):
```ini
[gcp_ansible_group_vault]
```

To make things easier to reference, the shorter-named `vault` group was defined in the [inventory file](inv.d/inventory) with `gcp_ansible_group_vault` as its children:
```ini
[vault:children]
gcp_ansible_group_vault
```

As was the `gcp` group name:
```ini
[gcp:children]
gcp_ansible_group_bastion
gcp_ansible_group_gitlab
gcp_ansible_group_vault
```

#### Overview of events

The majority of the network, disks and instances configuration are in a dictionary structure called `project_data` defined in the `localhost` [inventory vars file](inv.d/host_vars/localhost/gcp.yml)

Generally, the following steps will be performed when no tags are specified:

1. Create base network configuration:
    * A network
    * An external address (through which backend services will be reached)
    * Common firewall rules (All UDP/TDP ports on internal network, external SSH, etc)
    * A cloud router (to be used with Cloud NAT - see [limitations & known issues](#limitations-&-known-issues))
2. Create a bastion service (for managing internal, non internet-facing instances):
    * firewall rules
    * external interface for instance to use
    * disk & instance
3. Create a gitlab service:
    * firewall rules
    * No external interface
    * disk & instance
    * target pool & forwarding rules associated with base external address created in step 1 for external connectivity
4. Install GitLab software
5. Create a vault service:
    * firewall rules
    * No external interface
    * disk & instance (x3)
    * target pool & forwarding rules associated with base external address created in step 1 for external connectivity
6. Install & configure Vault cluster


#### Running the deployment

1. To create GCP instances & install GitLab + Vault Cluster
```
ansible-playbook playbooks/site.yml --extra-vars cloud_provider=gcp
```
__Note:__ Technically the `--extra-vars` is not needed as the default cloud is GCP.

2. To install GitLab & Vault to existing instances
```
ansible-playbook playbooks/site.yml --extra-vars cloud_provider=gcp --tags install
```

3. To destroy GCP GitLab & Vault deployment
```
ansible-playbook playbooks/site.yml --extra-vars cloud_provider=gcp --tags destroy
```

#### Limitations & known issues

1. Both GitLab & Vault services use HTTPS connections, however this deployment implements self-signed certificates. Although there is nothing strictly wrong with this for a development environment, you will receive certificate warnings when you connect to the services. It is recommended that you install certificates signed by a trusted CA if you choose to deploy into a production environment.

2. When vault is initialized, the master key shards & root token are stored in the ansible user's HOME dir on the Ansible control machine. This is __NOT__ good practice, but was used to get things running. It is recommended to read through Vault's [Seal/Unseal documentation page](https://www.vaultproject.io/docs/concepts/seal), in particular the section on [auto-unsealing](https://www.vaultproject.io/docs/concepts/seal#seal-unseal). Alternatively, this method of using [PGP, GPG, and Keybase](<https://www.vaultproject.io/docs/concepts/pgp-gpg-keybase.html>) unsealing might appeal.

##### GCP

1. Creating a VM without an external IP address, then re-running the create after changing the instance option to create an external IP address will create an external IP address but it will not attach it to the instance. You will need to attach this manually.

2. If you change an instance option to omit creating an external IP address after you have created it, the destruction of that instance will not remove the external IP address from the project resources.

3. Any shared firewall rule definitions can be deleted when destroying instances. It is recommended to put shared firewall definitions in the `base` service stanza in the `project_data` dictionary defined in the [gcp variables file](cloud-gitlab\inv.d\host_vars\localhost\gcp.yml).

4. The easiest way to allow internal instances to reach the internet for tasks such as installing/upgrading software is to enable Cloud NAT. Currently, there is no Ansible module to create a Cloud Gateway NAT resource. A Cloud Router resource called `project-router` is automatically created during the [`base_create.yml`](playbooks/base/base_create.yml) playbook, however a Cloud Gateway needs to be manually created to use it. It is recommended that as soon as the `create_base.yml` playbook has completed, you create the Cloud Gateway or else the internal instances will fail to install any software. Here's an example using the GCP Console:
![Alt text](images/Cloud-Gateway.jpg "Creating Cloud Gateway")
*I am considering off-loading this step to Terraform or using the `uri` module with the correct API call but until then this is a known issue*

