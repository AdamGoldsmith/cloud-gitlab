# Ansible Role: GitLab Runner Register

Registers runners with GitLab server

## Requirements

* Host with gitlab-runner installed

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
    gitlab_server_address: gitlab.example.com
    gitlab_server_port: 4483
```

Address and port of the GitLab server instance

```yaml
    gitlab_runner_registration_token: ""
```

Runner registration token. This can be found in the "Runner" section of the "Admin" page in the UI.

```yaml
    runner_docker_image: alpine:latest
```

Default docker image the runner uses

## Dependencies

None

## Example Playbook

```yaml
- name: GitLab Runner registration
  hosts: runner
  become: yes
  gather_facts: no

  vars_prompt:

    - name: runner_registration_token
      prompt: GitLab runner registration token (retrieve this from GitLab)?

  tasks:

    - name: Run gitlab runner registration role
      vars:
        gitlab_server_address: "gitlab.co.uk"
        gitlab_server_port: 4483
        gitlab_runner_registration_token: "{{ runner_registration_token }}"
      include_role:
        name: ansible-role-runner-register

```

## Known issues

* There is no idempotency on the registration process. If you run the same process multiple times it will keep registering the same runner(s) in the GitLab server instance.

## License

MIT

## Author Information

Adam Goldsmith, 2022
