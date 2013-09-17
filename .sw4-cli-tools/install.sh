#!/bin/bash

# Variable declaration
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMPDIR="${BASEDIR}/.tmp"

SOURCE_URL="http://files.shopware.de/download.php?package=install"
COUNT=1

# Get utils functions
source ${BASEDIR}/.sw4-cli-tools/utils.sh

## Verify MySQL-Connection
cfg.section.database

mysql -u ${user} -p${pass} -h ${host} -P ${port} -e ";" > /dev/null 2>&1
rc=$?
if [[ $rc != 0 ]] ; then
    create_error "Could not connect to MySQL-Server. Please review your MySQL-Credentials"
    echo; exit 1
fi

mysql -u ${user} -p${pass} -h ${host} -P ${port} -e "use ${database};" > /dev/null 2>&1
rc=$?
if [[ $rc != 0 ]] ; then
    create_error "Could not use Database '${database}'. Please review your MySQL-Databasename"
    echo; exit 1
fi

# Downloads the latest shopware 4 release using curl from files.shopware.de
# Skips the download process if a install.zip exists.
download_from_files() {
    create_headline "[${COUNT}.] Download latest version of \"Shopware 4\" from files.shopware.de"
    if [ -f "${TMPDIR}/install.zip" ]; then
        echo -e "install.zip already exists... ${txtylw}Skip downloading!${txtrst}"
    else
        curl -o ${TMPDIR}/install.zip ${SOURCE_URL}
    fi
    COUNT=$((${COUNT}+1))
}

# Decompresses the install.zip archive which will be used
# if the install method using files.shopware.de was selected.
# Unzips the install.zip to the ./.tmp/install
decompress_install_files() {
    # Decompress archive
    create_headline "[${COUNT}.] Decompress installation files"
    if [ ! -d "${TMPDIR}/install" ]; then
        mkdir ${TMPDIR}/install
        echo -n "Decompressing... "
        unzip -qo ${TMPDIR}/install.zip -d ${TMPDIR}/install &
        spinner $!
        echo -e "${txtgrn}Done!${txtrst}"
    else
        echo -e "\"install\" directory exists... ${txtylw}Skip decompressing!${txtrst}"
    fi
    COUNT=$((${COUNT}+1))
}

# Copies the files in ./.tmp/install to the configured
# install directory.
# Keep in mind that this method overwrites any existing files.
copy_files_to_path() {
    # Copy files to shop path
    create_headline "[${COUNT}.] Copy install files to shop path"
    cfg.section.shop
    if [ ! -d "${install_dir}" ]; then
        mkdir ${install_dir} -p
    fi

    rc=$?
    if [[ $rc != 0 ]] ; then
        create_error "Could not create install directory"
        echo; exit 1
    fi

    cp -R ${TMPDIR}/install/. ${install_dir}/ &
    echo -n "Copying files..."
    spinner $!
    echo -e "${txtgrn}Done!${txtrst}"

    COUNT=$((${COUNT}+1))
}

# Creates the configured database. If an database
# with the same name exists it will be dropped.
create_database() {
    # Create database
    create_headline "[${COUNT}.] Create MySQL database"
    cfg.section.database

    Q1="DROP DATABASE IF EXISTS ${database};"
    Q2="CREATE DATABASE IF NOT EXISTS ${database};"
    SQL="${Q1}${Q2}"
    echo -n "Create database..."
    mysql -u ${user} -p${pass} -h ${host} -P ${port} -e "${SQL}"
    echo -e "${txtgrn}Done!${txtrst}"

    COUNT=$((${COUNT}+1))
}

# Imports the shopware 4 tables using the provided
# sw4_clean.sql in the install/install directory
import_tables() {
    # Install shopware database
    create_headline "[${COUNT}.] Import shopware database"
    mysql -u ${user} -p${pass} -h ${host} -P ${port} ${database} < ${install_dir}/install/assets/sql/sw4_clean.sql &
    echo -n "Importing shopware tables..."
    spinner $!
    echo -e "${txtgrn}Done!${txtrst}"

    COUNT=$((${COUNT}+1))
}

# Creates the configured backend user. The password
# will be salted.
create_admin_user() {
    # Create backend user
    create_headline "[${COUNT}.] Create backend user"
    cfg.section.user
    SALT='A9ASD:_AD!_=%a8nx0asssblPlasS$'
    SALTED=`php -r "echo md5('${SALT}' . md5('${pass}'));"`
    SQL="INSERT INTO s_core_auth (roleID,username,password,localeID,name,email,active,admin,salted,lockeduntil)
    VALUES (
    1,'${user}', '${SALTED}',1, '${name}','${email}',1,1,1,'0000-00-00 00:00:00'
    );"
    echo -n "Creating admin-user \"${user}\"..."
    cfg.section.database
    mysql -u ${user} -p${pass} -h ${host} -P ${port} ${database} -e "${SQL}" &
    spinner $!
    echo -e "${txtgrn}Done!${txtrst}"

    COUNT=$((${COUNT}+1))
}

# Sets the configured shop email address. The configured
# password will be serialized.
set_shop_mail() {
    # Set shop mail
    create_headline "[${COUNT}.] Set shop eMail address"
    cfg.section.shop
    SHOPMAIL="$(php -r "echo serialize('${email}');")"
    Q1="DELETE FROM s_core_config_values WHERE element_id = (SELECT id FROM s_core_config_elements WHERE name='mail') AND shop_id = 1;"
    Q2="INSERT INTO s_core_config_values (id, element_id, shop_id, value) VALUES (NULL, (SELECT id FROM s_core_config_elements WHERE name='mail'), 1, '${SHOPMAIL}');"
    SQL="${Q1}${Q2}"
    echo -n "Setting eMail address to \"${email}\"..."
    cfg.section.database
    mysql -u ${user} -p${pass} -h ${host} -P ${port} ${database} -e "${SQL}" &
    spinner $!
    echo -e "${txtgrn}Done!${txtrst}"

    COUNT=$((${COUNT}+1))
}

# Sets the configured shop name. The configured
# shop name will be serialized.
set_shop_name() {
    # Set shop mail
    create_headline "[${COUNT}.] Set shop name"
    cfg.section.shop
    SHOPNAME="$(php -r "echo serialize('${name}');")"
    Q1="DELETE FROM s_core_config_values WHERE element_id = (SELECT id FROM s_core_config_elements WHERE name='shopName') AND shop_id = 1;"
    Q2="INSERT INTO s_core_config_values (id, element_id, shop_id, value) VALUES (NULL, (SELECT id FROM s_core_config_elements WHERE name='shopName'), 1, '${SHOPNAME}');"
    SQL="${Q1}${Q2}"
    echo -n "Setting shop name to \"${name}\"..."
    cfg.section.database
    mysql -u ${user} -p${pass} -h ${host} -P ${port} ${database} -e "${SQL}" &
    spinner $!
    echo -e "${txtgrn}Done!${txtrst}"

    COUNT=$((${COUNT}+1))
}

# Sets the configured host and path into the database
set_shop_host() {
    create_headline "[${COUNT}.] Set shop host and path"
    cfg.section.shop
    SQL="UPDATE s_core_shops SET name ='${name}', locale_id = 1, currency_id = 1, host = '${host}', base_path = '${path}', hosts = '${host}' WHERE \`default\` = 1;"
    echo -n "Setting shop host and path..."
    cfg.section.database
    mysql -u ${user} -p${pass} -h ${host} -P ${port} ${database} -e "${SQL}" &
    spinner $!
    echo -e "${txtgrn}Done!${txtrst}"
    COUNT=$((${COUNT}+1))
}

# Sets the configured database configuration into the config.php
# which is located in the configured install directory
prepare_config() {
    if [ -f ${install_dir}/config.php.dist ]; then
        cp ${install_dir}/config.php.dist ${install_dir}/config.php
    fi

    if [ ! -f ${install_dir}/config.php ]; then
    	touch ${install_dir}/config.php
    fi

    create_headline "[${COUNT}.] Prepare config.php"
    echo -n "Setting database configuration..."
    sed -i.bak "s/%db.user%/${user}/g" ${install_dir}/config.php
    sed -i.bak "s/%db.password%/${pass}/g" ${install_dir}/config.php
    sed -i.bak "s/%db.database%/${database}/g" ${install_dir}/config.php
    sed -i.bak "s/%db.host%/${host}/g" ${install_dir}/config.php
    sed -i.bak "s/%db.port%/${port}/g" ${install_dir}/config.php
    rm -f ${install_dir}/config.php.bak
    echo -e "${txtgrn}Done!${txtrst}"

    COUNT=$((${COUNT}+1))
}

# Sets the file and folder permissions on the required
# directory using 777
set_permissions() {
    # Set permissions
    create_headline "[${COUNT}.] Set file/folder permissions"
    echo -n "Setting permissions..."
    chmod -R 777 ${install_dir}/cache
    chmod -R 777 ${install_dir}/files
    chmod -R 777 ${install_dir}/engine/Library/Mpdf/tmp
    chmod -R 777 ${install_dir}/engine/Library/Mpdf/ttfontdata
    chmod -R 777 ${install_dir}/engine/Shopware/Plugins/Community
    chmod -R 777 ${install_dir}/media
    echo -e "${txtgrn}Done!${txtrst}"

    COUNT=$((${COUNT}+1))
}

# Call a bunch of functions
output_header
download_from_files
decompress_install_files
copy_files_to_path
create_database
import_tables
create_admin_user
set_shop_mail
set_shop_name
set_shop_host
prepare_config
set_permissions

echo
if [ -z "$OPERATION" ]; then
    echo "All done! Back to the main menu..."
    read
else
    echo "Done"
fi
