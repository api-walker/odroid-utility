#!/bin/bash

# ODROID Utility v2

# For debug uncomment
# set -x

# Global defines
_B="/usr/local/bin"

initialization() {
		if [ `whoami` != "root" ]; then
			sudo $0 $*
			exit $?
		fi

        # check what distro we are runnig.
        _R=`lsb_release -i -s`

        case "$_R" in
                "Ubuntu")
                        export DISTRO="ubuntu"
                        ;;
                "Debian")
						export DISTRO="debian"
						;;
                *)
                        echo "I couldn't identify your distribution."
                        echo "Please report this error on the forums"
                        echo "http://forum.odroid.com"
                        echo "debug info: "
                        lsb_release -a
                        exit 0
                        ;;
                esac        

		# if '--skip-update' is passed, then skip update of internals
	    if [ -z "$1" ]
		then
		   install_bootstrap_packages
		   update_internals
		elif [ "$1" == "--skip-update" ]
		then
		   echo 'Updates skipped'
	    elif [ "$1" == "--help" ]
		then
		   echo 'Help'
		   echo 'Arguments:'
		   echo '--skip-update - Skips update on start'
		   echo '--help - Shows this help'
		   echo 
		   echo 'About:'
		   echo 'This tool was developed to make configuration of your odroid easy.'
		   echo
		   echo 'Authors:'
		   echo 'Maintainer:  mdrjr'
		   echo 'Forker:  api-walker'
		   exit 0
		else
		   echo 'Usage'
		   echo 'sudo odroid-utility.sh [--skip-update]'
		   echo 'sudo odroid-utility.sh [--help]'
		   exit 0
		fi

		# start main application
		if [ -f $_B/config/config.sh ]; then
			source $_B/config/config.sh
		else
			echo "Error. Couldn't start"
			exit 0
		fi
}

install_bootstrap_packages() {

        case "$DISTRO" in
                "ubuntu")
                        apt-get -y install axel build-essential git xz-utils whiptail unzip wget curl
                        ;;
                 "debian")
						apt-get -y install axel wget curl unzip whiptail
						;;
				*)
				echo "Shouldn't reach here! Please report this on the forums."
				exit 0
				;;
		esac
}

update_internals() {
	echo "Performing scripts updates"
	baseurl="https://raw.githubusercontent.com/mdrjr/odroid-utility/master"

	FILES=`curl -s $baseurl/files.txt`
	APP_REV=`curl -s https://api.github.com/repos/mdrjr/odroid-utility/git/refs/heads/master | awk '{ if ($1 == "\"sha\":") { print substr($2, 2, 40) } }'`

	for fu in $FILES; do
		echo "Updating: $fu"
		rm -fr $_B/$fu
		curl -s $baseurl/$fu > $_B/$fu
	done

	export _REV="2.0 BETA GitRev: $APP_REV"

	chmod +x $_B/odroid-utility.sh
}

# Start the script
initialization $1
