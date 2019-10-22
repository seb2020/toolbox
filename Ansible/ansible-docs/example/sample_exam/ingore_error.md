# Ignore error and show msg

    ---
    - hosts: node2
    become: yes
    ignore_errors: yes
    tasks:
    - name: install fluffy
        yum:
        name: fluffy
        state: latest
    - debug:
        msg: "Attempted fluffy install!"