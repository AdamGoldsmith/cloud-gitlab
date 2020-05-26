# cloud-gitlab

Deploy GitLab CE into a cloud instance. Uses Jeff Geerling's [gitlab role](<https://galaxy.ansible.com/geerlingguy/gitlab/>) to install gitlab on the target instance.

#### Supported clouds

* Google Cloud Platform (GCP)
  * Ubuntu 16.04
  * CentOS 8 (default)

#### Requirements

* Pre-configured cloud provider credentials. For example, with GCP a service account JSON file
* SSH key pair for connecting to newly-created instance
* Ansible 2.7+ (tested with 2.9.4)

For further information refer to the [Google Cloud Platform Guide](https://docs.ansible.com/ansible/latest/scenario_guides/guide_gce.html)

#### Python3 virtual environment (recommended)

The steps below illustrate an example setup with a `python3` virtual environment.  There are many ways to achieve this goal but this is a simple method and assumes that you have `python3` installed on your linux environment.  For GCP:

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

It is worth noting, some people choose to connect to cloud-hosts via an SSH proxy (bastion) host to keep management and costs to a minimum.

This Ansible configuration uses a mixture of static & dynamic inventories residing in an inventory directory called `inv.d` (configured in `ansible.cfg`).

There is a group called `sshproxy` which has an associated `group_vars/sshproxy/vars.yml` file. In this file, if a remote Ansible host is detected on a public IP address, Ansible will attempt to connect directly to the target. However, if the host is detected on a private IP address, Ansible will set SSH Proxy arguments to connect to the target via the first SSH proxy host found in the `bastion` group.

Only hosts/groups in the `sshproxy` group will be affected by this process.

__Note:__ Considering that the GitLab instance has an external IP address, this configuration is opportunistically using the GitLab instance as an SSH proxy to avoid creating a dedicated bastion host and keep costs down, but it means you cannot create a vault environment without creating a GitLab instance.

##### GCP

*Until a method for automatically configuing the following is discovered...*

To force connections via an SSH proxy, edit `inv.d/inventory.gcp.yml` by uncommenting the following lines:
```yml
# hostnames:
#   - private_ip
```
This will force the dynamic inventory to return the internal IP addressses of instances. This will, in turn, set the appropriate SSH proxy arguments for all targets as described above.

#### Running the deployment

1. To create GCP instance & install GitLab
```
ansible-playbook playbooks/site.yml --extra-vars cloud_provider=gcp
```
__Note:__ Technically the `--extra-vars` is not needed as the default cloud is GCP.

2. To install GitLab to existing instance
```
ansible-playbook playbooks/site.yml --extra-vars cloud_provider=gcp --tags gitlab
```

3. To destroy GCP GitLab deployment
```
ansible-playbook playbooks/site.yml --extra-vars cloud_provider=gcp --tags destroy
```

#### Limitations & known issues

##### GCP

1. Creating a VM without an external IP address, then re-running the create after changing the instance option to create an external IP address will create an external IP address but it will not attach it to the instance. You will need to attach this manually.

2. If you change an instance option to omit creating an external IP address after you have created it, the destruction of that instance will not remove the external IP address from the project resources.

3. Any shared firewall rule definitions can be deleted when destroying instances.

4. Currently no Ansible module to create a Cloud NAT resource. A gateway playbook and role have been created to facilitate creating a squid proxy gateway on a VM but it is recommended to [manually enable Cloud NAT](https://cloud.google.com/nat/docs/using-nat#create_nat) for a more supported and less fiddly configuration. Currently, no automated configuration of the internal-only instances is performed as part of the gateway installation process.
