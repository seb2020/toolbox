# Block rescue

    ---
    - hosts: localhost
    become: yes
    tasks:
    - name: create file
        block:
        - file:
            name: /mnt/secret/newfile
            state: touch
        rescue:
        - name: output error message
            debug:
            msg: "Unable to create secret file"