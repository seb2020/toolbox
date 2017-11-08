# Change local in CentOS7
	
postgres@pgbox:/home/postgres/ [pg960final] export LANG="en_EN.UTF8"
postgres@pgbox:/home/postgres/ [pg960final] cat /proc/sysrq-trigger
cat: /proc/sysrq-trigger: Permission denied

The good thing with this approach is, that the setting is temporary and valid only for my current session. The default for that particular user and the system default will not be touched. But what when you want to make this persistent for this user? Easy as well:

postgres@pgbox:/home/postgres/ [pg960final] echo "LANG=\"en_EN.UTF8\"" >> ~/.bash_profile 
postgres@pgbox:/home/postgres/ [pg960final] echo "export LANG" >> ~/.bash_profile 

Once you have that every new session will have that set. The system default is defined in /etc/locale.conf:
	
postgres@pgbox:/home/postgres/ [pg960final] cat /etc/locale.conf 
LANG="en_US.UTF-8"