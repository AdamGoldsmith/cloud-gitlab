# ansible-role-vault-approle

Configure Hashicorp's vault by
* Enabling approle auth method
* Creating approle policy
* Creating approle role

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
vault_addr: "{{ ansible_fqdn }}"                                                # Vault listener address
vault_port: 8200                                                                # Vault listener port
vault_keysfile: "~/.hashicorp_vault_keys.json"                                  # Local file storing master key shards
approle_name: "approle"                                                         # Approle's name
bound_cidr: "0.0.0.0/0"                                                         # Permitted addresses to use approle
def_lease_ttl: "10m"                                                            # Default lease time to live
max_lease_ttl: "20m"                                                            # Max lease time to live
token_ttl: "10m"                                                                # Token time to live
max_token_ttl: "15m"                                                            # Token max time to live
```

## Dependencies

None

## Example Playbook

```yaml
---

- name: Create approle in Hashicorp Vault
  hosts: vault
  gather_facts: yes

  roles:
    - ansible-role-vault-approle
```

## License

MIT License

## Author Information

Adam Goldsmith
