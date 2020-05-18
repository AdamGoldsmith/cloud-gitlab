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

You will need valid credentials for GCP to be able to deploy the project.  This is covered in the [Credentials](https://docs.ansible.com/ansible/latest/scenario_guides/guide_gce.html#credentials) section of the Ansible GCP guide.  Assuming that you have created a `Service Account` and have the `.json` file downloaded you can perform the following example steps, pasting in and saving your `Service Account` .`json` contents at the `vi` step:

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
