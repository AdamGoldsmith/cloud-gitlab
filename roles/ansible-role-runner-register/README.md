# Ansible Role: GitLab Runner Register

Registers runners with GitLab server

## Requirements

1. For GitLab runners executing in Docker inside LXC containers, you will probably want to increase the sysctl `kernel.keys.maxkeys` vaule of the LXD HOST server
    ```bash
    sudo sc -c 'echo "kernel.keys.maxkeys = 5000" >> /etc/sysctl.conf'
    sudo sysctl -p /etc/sysctl.conf
    ```

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
