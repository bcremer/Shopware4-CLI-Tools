#!/bin/bash

# Variable declaration
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUPDIR="${BASEDIR}/backups"
DATE=`date +"%Y-%m-%d_%H:%M"`

# Get utils functions
source ${BASE}/utils.sh

# Parse config file
cfg_parser "${BASE}/config.ini"
cfg.section.script

# Set backup path if it's configured...
if [ ! -z ${backup_path} ]; then
    BACKUPDIR="${backup_path}"
fi

# Create backup directory
create_headline "[1.] Create backup directory"
if [ ! -d "${BACKUPDIR}" ]; then
    echo -n "Creating backup dir..."
    mkdir ${BACKUPDIR}
    chmod -R 777 ${BACKUPDIR}
    echo -e "${txtgrn}Done!${txtrst}"
else
    echo -e "backup directory already exists... ${txtylw}Skip creation!${txtrst}"
fi

# Create shop backup (files)
create_headline "[2.] Create shop backup"
cfg.section.shop

echo -n "Backing up shop files..."
cd ${install_dir}
tar cf ${BACKUPDIR}/backup-${DATE}.tar * &
spinner $!
echo -e "${txtgrn}Done!${txtrst}"

# Create MySQL dump of the configured database
create_headline "[3.] Create database backup"
cfg.section.database
echo -n "Backup up database \"${database}\"..."
mysqldump -u ${user} -p${pass} ${database} > ${BACKUPDIR}/backup-${database}-${DATE}.sql &
spinner $!
cd ${BACKUPDIR}
tar rf ${BACKUPDIR}/backup-${DATE}.tar backup-${database}-${DATE}.sql
rm -rf ${BACKUPDIR}/backup-${database}-${DATE}.sql
echo -e "${txtgrn}Done!${txtrst}"
cd ${BASE}

# Gzip the backup
create_headline "[4.] Gzip backup"
echo -n "Gzipping backup file..."
gzip -f ${BACKUPDIR}/backup-${DATE}.tar &
echo -e "${txtgrn}Done!${txtrst}"

echo
echo "Backup \"backup-${DATE}.tar.gzip\" created! Back to the main menu..."
read