# Shopware 4 CLI Tools

- **Release Date**: 21th December 2012
- **License**: MIT (see LICENSE-MIT)

## Overview
Shopware CLI Tools is a toolset designed to install Shopware 4 using the Shell (bash). Along with this abiliy we've built tools which should help you with everyday operations such as clearing the shop cache or backing up the live shop.

## Functionality
The script provides the following functionality:

- Installing Shopware 4 via the shell through files.shopware.de
- Setting up the basic shop configuration
- Clearing the shop cache including the staging system
- Creating a backup of the database and the shop files
- Installing the demo dataset from files.shopware.de

## Installation
You could install the toolset to any location you want, but we recommend installing the script into `/usr/local/bin`. If you're using any other location than `/usr/local/bin`, please add the new location to your `$PATH`

### Using Git

```bash
git clone https://github.com/ShopwareAG/Shopware4-CLI-Tools.git && cd Shopware4-CLI-Tools && sudo mv sw4-cli-tools /usr/local/bin/sw4-cli-tools && sudo mv .sw4-cli-tools /usr/local/bin/.sw4-cli-tools && sudo chmod -R 777 /usr/local/bin/sw4-cli-tools && sudo chmod -R 777 /usr/local/bin/.sw4-cli-tools
```

### Git-free installation
```bash
cd /usr/local/bin && curl -#L https://github.com/ShopwareAG/Shopware4-CLI-Tools/tarball/master | sudo tar -xzv --strip-components 1 --exclude={README.md,LICENSE-MIT} && sudo chmod -R 777 /usr/local/bin/sw4-cli-tools && sudo chmod -R 777 /usr/local/bin/.sw4-cli-tools 
```

### Specify the `$PATH`
Here’s an example that adds `/your/new/path` to the `$PATH`, which is needed if you want to install the toolset into any other directory than `/usr/local/bin`:
```bash
export PATH="/your/new/path:$PATH"
```

## Usage
If you've installed the toolset in `/usr/local/bin`, you simply could run the script in any directory using:
```bash
sw4-cli-tools
```

You can optionally pass a configuration file to configure multiple shopware instances on one machine:
```bash
sw4-cli-tools -c /path/to/shop.ini
sw4-cli-tools -c /path/to/other-shop.ini
```

You can use flags to directly perform operations:
```bash
-i Install
-d Install Demo Data
-k Clear Cache
```

Before you start any operation please modify the `config.ini` using the menu option `[6] Edit config.ini with "vim"` according to your needs.
