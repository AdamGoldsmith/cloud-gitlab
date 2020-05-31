# ansible-role-vault-unseal

Unseal Hashicorp's Vault by
* Starting Vault systemd service
* Retrieve locally saved Vault master key shards
* Unseal the Vault

Currently tested on these Operating Systems
* Oracle Linux/RHEL/CentOS
* Debian/Stretch64

## Requirements

* Ansible 2.5 or higher

## Role Variables

`defaults/main.yml`
```yaml
vault_tls_disable: "false"                                                      # Choose whether to disable TLS for vault connections (not advised)
vault_protocol: "{{ vault_tls_disable | bool | ternary('http', 'https') }}"     # HTTP/HTTPS connection to Vault service - default HTTPS
vault_addr: "{{ ansible_fqdn}}"                                                 # Vault listener address
vault_port: 8200                                                                # Vault listener port
vault_service: "vault"                                                          # Name of the vault systemd service
vault_keysfile: "~/.hashicorp_vault_keys.json"                                  # Local file storing master key shards
key_threshold: 3                                                                # Minimum number of keys for unseal quorum
```

## Dependencies

Requires elevated root privileges

## Example Playbook

```yaml
---

- name: Unseal Hashicorp Vault
  hosts: vault
  become: yes
  gather_facts: yes

  roles:
    - ansible-role-vault-unseal
```

## License

MIT License

## Author Information

Adam Goldsmith
