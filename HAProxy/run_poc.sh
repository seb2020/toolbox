#!/bin/sh

# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.

#################################################################################
#
# Script: run_poc.sh
# Purpose : Build and start a POC for HAProxy Config
#
################################################################################

# Create folder
mkdir /opt/www
mkdir /opt/www/admin
mkdir /opt/www/api

# Create dummy webpage
cat > /opt/www/index.php << EOL
<html>
<body>
<h1>base</h1>
<h2><?php if($_ENV["HOSTNAME"]) {?><h3>My hostname is <?php echo $_ENV["HOSTNAME"]; ?></h3><?php } ?></h2>
</body>
</html>
EOL

cat > /opt/www/admin/index.php << EOL
<html>
<body>
<h1>admin</h1>
<h2><?php if($_ENV["HOSTNAME"]) {?><h3>My hostname is <?php echo $_ENV["HOSTNAME"]; ?></h3><?php } ?></h2>
</body>
</html>
EOL

cat > /opt/www/api/index.php << EOL
<html>
<body>
<h1>api</h1>
<h2><?php if($_ENV["HOSTNAME"]) {?><h3>My hostname is <?php echo $_ENV["HOSTNAME"]; ?></h3><?php } ?></h2>
</body>
</html>
EOL

# Run docker with mount
docker stop www
docker stop www-api
docker stop www-admin

# Delete container
docker rm www
docker rm www-api
docker rm www-admin

# Run
docker run -p 7000:80 -v /opt/www/:/var/www/html/ --name www -d eboraas/apache-php 
docker run -p 8000:80 -v /opt/www/:/var/www/html/ --name www-api -d eboraas/apache-php 
docker run -p 9000:80 -v /opt/www/:/var/www/html/ --name www-admin -d eboraas/apache-php 
