# ansible-role-vault-init

Initialise Hashicorp's vault by
* Starting vault systemd service
* Initialise the vault
* Save keys locally

Currently tested on these Operating Systems
* Oracle Linux/RHEL/CentOS
* Debian/Stretch64

## Requirements

* Ansible 2.5 or higher

## Role Variables

`defaults/main.yml`
```yaml
vault_tls_disable: "false"                                                                      # Choose whether to disable TLS for vault connections (not advised)
vault_protocol: "{{ vault_tls_disable | bool | ternary('http', 'https') }}"                     # HTTP/HTTPS connection to Vault service - default HTTPS
vault_addr: "{{ ansible_fqdn }}"								# Vault listener address
vault_port: 8200										# Vault listener port
vault_certs: "/etc/vault/certs"									# Vault certificates directory
vault_certfile: "{{ vault_certs }}/{{ansible_fqdn | regex_replace('^www\\.', '') }}.crt"	# OpenSSL Certificate filename
vault_user: "vault"										# User to run the vault systemd service
vault_group: "vault"										# Group for vault user
vault_service: "vault"										# Name of the vault systemd service
vault_keysfile: "~/.hashicorp_vault_keys.json"							# Local file storing master key shards
```

## Dependencies

Requires elevated root privileges

## Example Playbook

```yaml
---

- name: Initialise Hashicorp Vault
  hosts: vault
  gather_facts: yes
  become: yes

  roles:
    - ansible-role-vault-init
```

## License

MIT License

## Author Information

Adam Goldsmith
