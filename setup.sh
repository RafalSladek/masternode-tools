#!/bin/bash
#set -xu

echo "setting up everything ..."

SCRIPT=$(readlink -f "$0")
SOURCEPATH=$(dirname "$SCRIPT")
TARGETPATH=/usr/local/bin

# list all executable scripts recursively and create new links
find "$SOURCEPATH" -type f -executable -not -path "*.git*" -not -path "*/datadog-dashboards"  | while read -r script; do
    script_name=$(basename "$script")
    
    # Remove old link if it exists
    if [ -L "$TARGETPATH/$script_name" ]; then
        rm -rf "$TARGETPATH/$script_name" && echo "removed old $TARGETPATH/$script_name"
    fi
    # Create new symlink
    ln -s "$script" "$TARGETPATH/$script_name" && echo "linked new $script to $TARGETPATH/$script_name"
done

cd "$TARGETPATH" || exit

echo "deleting invalid links..."
find . -xtype l -exec rm {} \;

echo "verify deletion of invalid links"
find . -xtype l

echo "list of existing links.."
ls -lhaF | grep ^l

# run tools setup
source /usr/local/bin/tools.sh

ls -al $TARGETPATH
