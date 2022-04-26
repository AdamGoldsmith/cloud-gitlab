# Ansible Role: GitLab restore

Restores a GitLab instance.
Copies the backup file, plus additional sensitive files, from the localhost to the GitLab instance, then restores GitLab.
This role will find all the files in the localhost's backup dir then copy them in place on the GitLab instance.
Unless the backup timestamp is specified, the latest timestamped file will be used.

## Requirements

* The GitLab backup files on the localhost

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
    local_backup_dest: /var/tmp/gitlab_backup
```

Directory on localhost of backup files destination

```yaml
    gitlab_backup_timestamp: ""
```

If specified, the restore process will use this backup timestamp to identify the backup file to restore from. If not specified, the latest backup file will be used.

## Dependencies

None

## Example Playbook

```yaml

- name: GitLab configuration restore
  hosts: gitlab
  become: yes
  gather_facts: no
  tags:
    - never
    - gitlab_restore

  tasks:

    - name: Run gitlab restore role
      include_role:
        name: ansible-role-gitlab-restore
```

## License

MIT

## Author Information

Adam Goldsmith, 2022
