# Create a vault file

    ansible-vault create /home/ansible/exam/secure
    myvar: content

# Create playbook

    --- 
    - hosts: localhost
    vars_files:
        - /home/ansible/exam/secure
    become: yes
    tasks:
        - name: create classified directory
        file:
            state: touch
            name: /mnt/classified
        - name: insert myvar text into file
        lineinfile:
            path: /mnt/classified
            line: "{{ myvar }}"

# Run playbook

    ansible-playbook exam/security.yml --ask-vault-pass