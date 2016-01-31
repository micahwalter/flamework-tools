#!/bin/sh

WHOAMI=`python -c 'import os, sys; print os.path.realpath(sys.argv[1])' $0`
UBUNTU=`dirname $WHOAMI`

PROJECT=`dirname $UBUNTU`

DBNAME=$2
USERNAME=$3

# We probably don't care about any errors...
PHP='php -d display_errors=off -q'

PASSWORD=`${PHP} ${PROJECT}/bin/generate_secret.php`

echo "CREATE DATABASE ${DBNAME};" > /tmp/${DBNAME}.sql
echo "CREATE user '${USERNAME}'@'localhost' IDENTIFIED BY '${PASSWORD}';" >> /tmp/${DBNAME}.sql
echo "GRANT SELECT,UPDATE,DELETE,INSERT ON ${DBNAME}.* TO '${USERNAME}'@'localhost' IDENTIFIED BY '${PASSWORD}';" >> /tmp/${DBNAME}.sql
echo "FLUSH PRIVILEGES;" >> /tmp/${DBNAME}.sql

echo "USE ${DBNAME};" >> /tmp/${DBNAME}.sql;

for f in `ls -a ${PROJECT}/schema/*.schema`
do
	echo "" >> /tmp/${DBNAME}.sql
	cat $f >> /tmp/${DBNAME}.sql
done

mysql -u root -p < /tmp/${DBNAME}.sql

unlink /tmp/${DBNAME}.sql

# TO DO: UPDATE www/include/config.php HERE
# TO DO: UPDATE www/include/secrets.php HERE
# (20160130/thisisaaronland)

echo ""
echo "\t------------------------------";

echo "\t\$GLOBALS['cfg']['db_main'] = array(";
echo "\t\t'host' => 'localhost',";
echo "\t\t'user' => '${USERNAME}',";
echo "\t\t'pass' => '${PASSWORD}',";
echo "\t\t'name' => '${DBNAME}',";
echo "\t\t'auto_connect' => 0,";
echo "\t);";

echo "\t------------------------------";
echo "";
