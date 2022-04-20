# Ansible Role: GitLab Runner

Installs GitLab runner on any RedHat/CentOS or Debian/Ubuntu linux system. You will still need to register this runner manually.

## Requirements

None

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
    runner_download_validate_certs: true
```

Controls whether to validate certificates when downloading the GitLab installation repository install script

```yaml
    runner_repository_installation_script_url: "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.xxx.sh"
```

OS-specific repository installation script (see `vars/<OS Family>.yml`)

## Dependencies

None

## Example Playbook

```yaml
    - name: Install GitLab Runner
    hosts: runner
    become: yes
    gather_facts: yes

    pre_tasks:

        - name: Update apt cache
        apt:
            update_cache: yes
        when: ansible_os_family == 'Debian'

    tasks:

        - name: Run gitlab runner installation role
        include_role:
            name: ansible-role-runner

        roles:
            - { role: geerlingguy.gitlab }
```

## License

MIT

## Author Information

Adam Goldsmith, 2022
