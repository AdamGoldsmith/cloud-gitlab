# ansible-role-vault-remove

Removes Hashicorp's Vault by
* Removing VAULT_ADDR system-wide profile
* Stopping & disabling Vault systemd service
* Deleting Vault systemd service configuration file
* Removing the Vault directory structure
* Removing the Vault user & group
* Removing binary vault from /usr/bin

Currently tested on these Operating Systems
* Oracle Linux/RHEL/CentOS
* Debian/Stretch64

## Requirements

* Ansible 2.5 or higher

## Role Variables

`defaults/main.yml`
```yaml
vault_bin_path: "/usr/bin"				# Path to install vault binary
vault_conf: "/etc/vault/config.hcl"			# Vault configuration file
vault_certs: "/etc/vault/certs"				# Vault certificates directory
vault_user: "vault"					# User to run the vault systemd service
vault_group: "vault"					# Group for vault user
vault_service: "vault"					# Name of the vault systemd service
vault_profile: "/etc/profile.d/vault.sh"		# System-wide profile for setting Vault listening address
audit_path: "/var/log/vault"				# Audit log file directory
```

## Dependencies

Requires elevated root privileges

## Example Playbook

```yaml
---

- name: Remove Hashicorp Vault
  hosts: vault
  become: yes

  roles:
    - ansible-role-vault-remove
```

## License

MIT License

## Author Information

Adam Goldsmith
