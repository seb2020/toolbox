# Download file

Download yml file and create users

        ---
        - hosts: localhost
        tasks:
        - name: download user_list.yml
            get_url:
            url: http://files.example.com/user_list.yml
            dest: /home/ansible/files/user_list.yml

        - hosts: node1
        become: yes
        vars_files:
            - /home/ansible/files/user_list.yml
        tasks:
        - name: create groups from file
            group: 
            name: "{{ item }}"
            with_items:
            - "{{ user_groups }}"
        - name: create users for each group in staff
            user:
            name: "{{ item }}"
            group: staff
            with_items:
            - "{{ staff }}"
        - name: create users for each group in students
            user:
            name: "{{ item }}"
            group: students
            with_items:
            - "{{ students }}"
        - name: create users for each group in faculty
            user:
            name: "{{ item }}"
            group: faculty
            with_items:
            - "{{ faculty }}"