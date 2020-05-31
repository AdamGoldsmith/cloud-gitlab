# ansible-role-vault-start

Start Hashicorp's Vault by
* Starting the Vault service

Currently tested on these Operating Systems
* Oracle Linux/RHEL/CentOS
* Debian/Stretch64

## Requirements

Ansible 2.5 or higher

## Role Variables

`defaults/main.yml`
```yaml
vault_service: vault		# Name of the vault systemd service
```

## Dependencies

None

## Example Playbook

```yaml
---

- name: Start Hashicorp Vault
  hosts: vault
  become: yes

  roles:
    - ansible-role-vault-start
```

## License

MIT License

## Author Information

Adam Goldsmith
