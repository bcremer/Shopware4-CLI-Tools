#!/bin/bash

# Variable declaration
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get utils functions
source ${BASEDIR}/.sw4-cli-tools/utils.sh

# Clear template cache
create_headline "[1.] Clear template cache"
echo -n "Deleting template cache files..."
rm -rf ${install_dir}/cache/templates/* &
spinner $!
echo -e "${txtgrn}Done!${txtrst}"

create_headline "[2.] Clear database cache"
echo -n "Deleting database cache files..."
rm -rf ${install_dir}/cache/database/* &
spinner $!
echo -e "${txtgrn}Done!${txtrst}"

create_headline "[3.] Delete Proxies"
echo -n "Deleting Proxies files..."
rm -rf ${install_dir}/engine/Shopware/Proxies/* &
spinner $!
echo -e "${txtgrn}Done!${txtrst}"

create_info_headline "Do you want to clear the cache of the staging system?"
echo -n "Enter your choice [y-n]: "
read staging

if [ ${staging} = 'y' ]; then
    create_headline "[4.] Clear staging template cache"
    echo -n "Deleting template cache files..."
    rm -rf ${install_dir}/staging/cache/templates/* &
    spinner $!
    echo -e "${txtgrn}Done!${txtrst}"

    create_headline "[2.] Clear staging database cache"
    echo -n "Deleting staging database cache files..."
    rm -rf ${install_dir}/staging/cache/database/* &
    spinner $!
    echo -e "${txtgrn}Done!${txtrst}"

    create_headline "[3.] Delete staging Proxies"
    echo -n "Deleting staging Proxies files..."
    rm -rf ${install_dir}/engine/Shopware/ProxiesStaging/* &
    spinner $!
    echo -e "${txtgrn}Done!${txtrst}"
fi

echo
if [ -z "$OPERATION" ]; then
    echo "All done! Back to the main menu..."
    read
else
    echo "Done"
fi 
