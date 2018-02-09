# Infos

## Set up ssh keys on ansible server

    ssh-keygen -b 4096 -t rsa
    ssh-copy-id -i .ssh/id_rsa.pub root@CLIENTS

## Playbook

### Playbook debug

    [root@SRVLNXMGNT-01 deploy]# ansible -i inventory/xxx/test/hosts all -m ping
    [root@SRVLNXMGNT-01 deploy]# ansible -i inventory/xxx/test/hosts all -m setup --tree /etc/ansible/facts.d/
    [root@SRVLNXMGNT-01 deploy]# ansible-playbook -i inventory/xxx/prod/hosts roles/debug/tasks/main.yml