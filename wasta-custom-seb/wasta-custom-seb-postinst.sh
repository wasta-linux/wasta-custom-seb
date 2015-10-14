#!/bin/bash

# ==============================================================================
# wasta-custom-seb-postinst.sh
#
#   This script is automatically run by the postinst configure step on
#       installation of wasta-custom-seb.  It can be manually re-run, but is
#       only intended to be run at package installation.  
#
#   2015-03-06 rik: initial script
#
# ==============================================================================

# ------------------------------------------------------------------------------
# Check to ensure running as root
# ------------------------------------------------------------------------------
#   No fancy "double click" here because normal user should never need to run
if [ $(id -u) -ne 0 ]
then
	echo
	echo "You must run this script with sudo." >&2
	echo "Exiting...."
	sleep 5s
	exit 1
fi

# ------------------------------------------------------------------------------
# Initial Setup
# ------------------------------------------------------------------------------

echo
echo "*** Beginning wasta-custom-seb-postinst.sh"
echo

# ------------------------------------------------------------------------------
# LibreOffice Preferences Extension install (for all users)
# ------------------------------------------------------------------------------

# Install wasta-ssg-defaults.oxt (Default LibreOffice Preferences)

#echo
#echo "*** Installing Wasta-Linux LO ODF Default Settings Extension (for all users)"
#echo
#unopkg add --shared /usr/share/wasta-custom-seb/resources/wasta-english-intl-odf-defaults.oxt

# IF user has not initialized LibreOffice, then when adding the above shared
#   extension, the user's LO settings are created, but owned by root so
#   they can't change them: solution is to just remove them (will get recreated
#   when user starts LO the first time).

for LO_FOLDER in /home/*/.config/libreoffice;
do
    LO_OWNER=$(stat -c '%U' $LO_FOLDER)

    if [ "$LO_OWNER" == "root" ];
    then
        echo
        echo "*** LibreOffice settings owned by root: resetting"
        echo "*** Folder: $LO_FOLDER"
        echo
    
        rm -rf $LO_FOLDER
    fi
done

# For ALL users, delete LO config folder if older than specified date
#   (this will ensure that ODF file extensions used by system extension above)
#   since will be re-created when LO launched.  Effectively we are resetting
#   LO preferences.

# Create file with modified date of desired comparison time
#   so that don't remove a user's updated files if they have made a
#   custom update to them.
COMPFILE=$(mktemp)
touch $COMPFILE -d '2015-04-03'

delOldFile "/home/*/.config/libreoffice/" $COMPFILE "YES"

# remove comparison time file
rm $COMPFILE

# ------------------------------------------------------------------------------
# Set system-wide Paper Size
# ------------------------------------------------------------------------------
# Note: This sets /etc/papersize.  However, many apps do not look at this
#   location, but instead maintain their own settings for paper size :-(
paperconfig -p a4

# ------------------------------------------------------------------------------
# Finished
# ------------------------------------------------------------------------------

echo
echo "*** Finished with wasta-custom-seb-postinst.sh"
echo

exit 0
