# ansible-role-vault-install

Installs Hashicorp's Vault by
* Downloading & unzipping Vault from Hashicorp's releases site into /usr/bin
* Creating a Vault group & user
* Creating the Vault directory structure
* Installing latest version of cryptography using pip
* Generating self-signed SSL/TLS certificates
* Creating Vault systemd service
* Starting & enabling Vault systemd service
* Setting VAULT_ADDR & VAULT_CACERT in system-wide profile

Currently tested on these Operating Systems
* Oracle Linux/RHEL/CentOS 7
* Debian/Stretch64

## Requirements

* Ansible 2.5 or higher
* __Centos__ : Enable EPEL repository

  EPEL is not enabled in this role, try Jeff Geerling's [EPEL role](<https://galaxy.ansible.com/geerlingguy/repo-epel/>)

## Role Variables

`defaults/main.yml`
```yaml
vault_src: "https://releases.hashicorp.com/vault/0.10.3/vault_1.9.3_linux_amd64.zip"	# Version of vault to download from Hashicorp's website
vault_chksum: "sha256:16059f245fb4df2800fe6ba320ea66aba9c2615348e37bcfd42754591a528639"	# Vault download file checksum
vault_bin_path: "/usr/bin"								# Path to install vault binary
vault_conf: "/etc/vault/config.hcl"							# Vault configuration file
vault_tls_disable: "false"								# Choose whether to disable TLS for vault connections (not advised)
vault_mlock_disable: "false"              # Disbale mlock - sometimes required for the infrastructure (eg LXD)
vault_certs: "/etc/vault/certs"								# Vault certificates directory
vault_cn: "{{ ansible_fqdn }}"								# CSR Common Name
vault_cc: "UK"										# CSR Country Code
vault_on: "Vault"									# CSR Organization Name
vault_privkey: "{{ vault_certs }}/{{ vault_cn | regex_replace('^www\\.', '') }}.pem"	# OpenSSL Private Key filename
vault_csr: "{{ vault_certs }}/{{ vault_cn }}.csr"					# OpenSSL Certificate Signing Request filename
vault_certfile: "{{ vault_certs }}/{{ vault_cn | regex_replace('^www\\.', '') }}.crt"	# OpenSSL Certificate filename
vault_protocol: "{{ vault_tls_disable | bool | ternary('http', 'https') }}"             # HTTP/HTTPS connection to Vault service - default HTTPS
vault_addr: "{{ ansible_fqdn }}"							# Vault listener address
vault_port: 8200									# Vault listener port
vault_cluster_port: 8201								# Vault cluster port
vault_user: "vault"									# User to run the vault systemd service
vault_uid: "8201"									# UID of vault user
vault_group: "vault"									# Group for vault user
vault_gid: "8201"									# GID of vault group
vault_service: "vault"									# Name of the vault systemd service
vault_profile: "/etc/profile.d/vault.sh"						# System-wide profile for setting Vault listening address
vault_data_path: "/data/vault"                                                          # Backend raft storage directory
vault_ui: "true"                                                                        # Enable Web UI
```

## Dependencies

Requires elevated root privileges

## Example Playbook

```yaml
---

- name: Install Hashicorp Vault
  hosts: vault
  become: yes
  gather_facts: yes

  roles:
    - ansible-role-vault-install
```

## License

MIT License

## Author Information

Adam Goldsmith
