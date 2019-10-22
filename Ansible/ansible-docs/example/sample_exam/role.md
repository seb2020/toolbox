# Install role with playbook

    ---
    - hosts: localhost
    tasks:
        - name: install role
          command: ansible-galaxy install elastic.elasticsearch