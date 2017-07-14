# StackSetup
Currently supports:          apache2, nginx, django, php7.0, mysql
<br>Current Planned Updates: mariadb, LetsEncrypt

This is an all in one, single script solution to setting up server stacks. No instructions are included, though it is well commented. This is configured for a Proxmox or similar LXC environment, as such django does not utilize pip (at this time) though it is installed. If you don't know what LXC is or to do with a .sh file, this is probably not for you.

Every install is wrapped in it's own function. Any install that requires a previous install (like the slight differences in installing php for nginx and apache2) checks that it has already been done before running.

Licensed under MIT. License is included in file.
