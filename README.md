# StackSetup
Currently supports:          apache2, nginx, php7.0, mysql
<br>Current Planned Updates:     python, mariadb

This is an all in one, single script solution to setting up server stacks. No instructions are included, though it is well commented. If you don't know what to do with a .sh file, this is probably not for you.

Every install is wrapped in it's own function. Any install that requires a previous install (like the slight differences in installing php for nginx and apache2) checks that it has already been done before running.
