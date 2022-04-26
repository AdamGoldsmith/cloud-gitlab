# Ansible Role: GitLab backup

Backs up the GitLab instance then fetches the backup file, plus additional sensitive files, to the localhost.
In addition, this role will find and fetch the following host SSH keys:
* `/etc/ssh/ssh_host_*_key`
* `/etc/ssh/ssh_host_*_key.pub`

## Requirements

None

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
    local_backup_dest: /var/tmp/gitlab_backup
```

Directory on localhost of backup files destination

```yaml
    gitlab_backup_path: /var/opt/gitlab/backups
```

Directory on GitLab host where the backups are written to by the `gitlab-backup create` command

```yaml
    gitlab_backup_files:
      - /etc/gitlab/gitlab.rb
      - /etc/gitlab/gitlab-secrets.json
      - /etc/gitlab/ssl/gitlab.crt
      - /etc/gitlab/ssl/gitlab.key
```

Additional list of files to include in the fetch to localhost

## Dependencies

None

## Example Playbook

```yaml

- name: GitLab configuration backup
  hosts: gitlab
  become: yes
  gather_facts: no
  tags:
    - never
    - gitlab_backup

  tasks:

    - name: Run gitlab backup role
      include_role:
        name: ansible-role-gitlab-backup
```

## License

MIT

## Author Information

Adam Goldsmith, 2022
