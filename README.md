# Shopware 4 CLI Tools

- **Version**: 1.0
- **Release Date**: 20th December 2012
- **License**: MIT (see LICENSE-MIT)

## Overview
Shopware CLI Tools is a toolset with the aim to install Shopware 4 using the Shell (bash). Along with this abiliy we've build tools which should help you with everyday operations like clearing the shop cache or backing up the running shop.

## Functionality
The script provides the following functionality:

- Install Shopware 4 via the shell through files.shopware.de
- Setting up the basic shop configuration
- Clear the shop cache including the staging system
- Create a backup of the database and the shop files
- Install the demo dataset from files.shopware.de

## Installation
You could install the toolset to any location you want, but we recommend to install the script into `/usr/local/bin`. If you're using any other location than `/usr/local/bin`, please add the new location to your `$PATH`

### Using Git

```bash
cd /usr/local/bin & git clone https://github.com/ShopwareAG/Shopware4-CLI-Tools.git & cd chmod -R 777 Shopware4-CLI-Tools
```

### Git-free installation
```bash
cd /usr/local/bin; curl -#L  https://github.com/ShopwareAG/Shopware4-CLI-Tools/tarball/master | tar -xzv --strip-components 1 --exclude={README.md,LICENSE-MIT}
```

### Specify the `$PATH`
Here’s an example `~/.path` file that adds `/your/new/path` to the `$PATH`:
```bash
export PATH="/your/new/path:$PATH"
```

## Usage
If you've installed the toolset in `/usr/local/bin`, you simply could run the script in any directory using:
```bash
sw4-cli-tools
```

Before you start any operation please modify the `config.ini` using the menu option `[6] Edit config.ini with "vim"` to your needs.

## Release History
- 2012-12-20 - Initial release