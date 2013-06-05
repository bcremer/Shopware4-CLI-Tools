#!/bin/bash

# Variable declaration
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMPDIR="${BASEDIR}/.tmp"
SOURCE_URL="http://files.shopware.de/download.php?package=demo"

# Get utils functions
source ${BASEDIR}/.sw4-cli-tools/utils.sh

# Download demo data
create_headline "[1.] Download latest version of demo-data from files.shopware.de"
if [ -f "${TMPDIR}/demo.zip" ]; then
    echo -e "demo.zip already exists... ${txtylw}Skip downloading!${txtrst}"
else
    curl -o ${TMPDIR}/demo.zip ${SOURCE_URL}
fi

# Decompress archive
create_headline "[2.] Decompress demo files"
if [ ! -d "${TMPDIR}/demo" ]; then
    mkdir ${TMPDIR}/demo
    echo -n "Decompressing... "
    unzip -qo ${TMPDIR}/demo.zip -d ${TMPDIR}/demo &
    spinner $!
    echo -e "${txtgrn}Done!${txtrst}"
else
    echo -e "\"demo\" directory exists... ${txtylw}Skip decompressing!${txtrst}"
fi

# Move files to the install dir
create_headline "[3.] Copy install files to shop path"
cfg.section.shop
if [ ! -d "${install_dir}" ]; then
    mkdir ${install_dir}
fi
cp -R ${TMPDIR}/demo/files ${install_dir}/ &
echo -n "Copying files directory..."
spinner $!
echo -e "${txtgrn}Done!${txtrst}"

cp -R ${TMPDIR}/demo/media ${install_dir}/ &
echo -n "Copying media directory..."
spinner $!
echo -e "${txtgrn}Done!${txtrst}"

 # Install shopware database
create_headline "[4.] Import demo.sql"
cfg.section.database
mysql -u ${user} -p${pass} -h ${host} -P ${port} ${database} < ${TMPDIR}/demo/demo.sql &
echo -n "Importing demo.sql..."
spinner $!
echo -e "${txtgrn}Done!${txtrst}"

create_info_headline "[!] Keep in mind that your username and password is now \"demo\"!"

if [ -z "$OPERATION" ]; then
    echo "All done! Back to the main menu..."
    read
else
    echo "Done"
fi 
