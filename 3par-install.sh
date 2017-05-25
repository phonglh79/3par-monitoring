#!/usr/bin/env bash
#
# 3par-install.sh
# This file is part of 3par monitoring.
# 3par monitoring is a shell based client to obtain and gather 3par StoreServ
# storage array statistics by using CLI and ssh.
#
# Copyright (C) 2017 Robert M Holyst
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Looking for existing installation
if [[ -f /usr/bin/3par-daemon ]]; then
	INSTALLATION=1
elif [[ -f /usr/bin/3par ]]; then
        INSTALLATION=1
elif [[ -f /etc/systemd/system/3par.service ]]; then
        INSTALLATION=1
elif [[ -f /usr/share/man/man1/3par.1.gz ]]; then
        INSTALLATION=1
else
	INSTALLATION=0
fi

# Obtaining options if existing installation has been detected
if [[ ${INSTALLATION} -eq 1 ]]; then
	printf '\n%s\n\n' "Prevoius installation has been detected."
	printf '%s\n' "Please select:"
	printf '\t%s\t%s\n' "i" "- to make a fresh installation"
	printf '\t%s\t%s\n' "u" "- to update existing installation"
	printf '\t%s\t%s\n\n' "r" "- to remove existing installation"
	read -p "[i/u/r]: " OPTION
elif [[ ${INSTALLATION} -eq 0 ]]; then
	OPTION="i"
fi

# Looking for wget availability
if [[ ${OPTION} =~ ^[iu]{1}$ ]]; then
	command -v wget >/dev/null
	if [[ $? -ne 0 ]]; then
		printf '%s\t%s\n' "[INF]" "Installing wget"
		yum -y install wget >/dev/null 2>&1
		if [[ $? -ne 0 ]]; then
			printf '%s\t%s\n\n' "[ERR]" "Installation failed"
			exit 1
		fi
	fi
fi

# Handling options
case "${OPTION}" in

	i|u)
		# Pulling 3par
		printf '%s\t%s\n' "[INF]" "Pulling 3par"
		wget -O /usr/bin/3par https://raw.githubusercontent.com/robertmholyst/3par-monitoring/master/3par >/dev/null 2>&1
		if [[ $? -ne 0 ]]; then
			printf '%s\t%s\n\n' "[ERR]" "3par installation failed"
			exit 1
		fi
		chmod 755 /usr/bin/3par

		# Pulling 3par-daemon
        	printf '%s\t%s\n' "[INF]" "Pulling 3par-daemon"
        	wget -O /usr/bin/3par-daemon https://raw.githubusercontent.com/robertmholyst/3par-monitoring/master/3par-daemon >/dev/null 2>&1
        	if [[ $? -ne 0 ]]; then
                	printf '%s\t%s\n\n' "[ERR]" "3par-daemon installation failed"
                	exit 1
        	fi
		chmod 755 /usr/bin/3par-daemon

		# Pulling 3par.service
        	printf '%s\t%s\n' "[INF]" "Pulling 3par.service"
        	wget -O /etc/systemd/system/3par.service https://raw.githubusercontent.com/robertmholyst/3par-monitoring/master/3par.service >/dev/null 2>&1
        	if [[ $? -ne 0 ]]; then
                	printf '%s\t%s\n\n' "[ERR]" "3par.service installation failed"
                	exit 1
        	fi
		systemctl daemon-reload
		if [[ ${OPTION} == u ]]; then
			systemctl restart 3par.service
		fi

		if [[ ${OPTION} != u ]]; then

			# Creating configuration directory
			printf '%s\t%s\n' "[INF]" "Creating configuration directory"
			rm -rf /etc/3par 2>/dev/null
			mkdir /etc/3par 2>/dev/null
			if [[ $? -ne 0 ]]; then
                		printf '%s\t%s\n\n' "[ERR]" "Directory creation failed"
                		exit 1
        		fi

			# Pulling 3par.cfg
        		printf '%s\t%s\n' "[INF]" "Pulling 3par.cfg"
        		wget -O /etc/3par/3par.cfg https://raw.githubusercontent.com/robertmholyst/3par-monitoring/master/3par.cfg >/dev/null 2>&1
        		if [[ $? -ne 0 ]]; then
                		printf '%s\t%s\n\n' "[ERR]" "3par.cfg installation failed"
                		exit 1
        		fi
        		chmod 600 /etc/3par/3par.cfg
		fi

		# Pulling 3par.1
        	printf '%s\t%s\n' "[INF]" "Pulling 3par.1"
        	wget -O /usr/share/man/man1/3par.1 https://raw.githubusercontent.com/robertmholyst/3par-monitoring/master/3par.1 >/dev/null 2>&1
        	if [[ $? -ne 0 ]]; then
                	printf '%s\t%s\n\n' "[ERR]" "3par.1 installation failed"
                	exit 1
        	fi
		gzip -f /usr/share/man/man1/3par.1
		chmod 644 /usr/share/man/man1/3par.1.gz

		printf '\n%s\n\n' "3par has been installed"
		;;

	r)
		# Stopping 3par-daemon
		printf '%s\t%s\n' "[INF]" "Stopping 3par-daemon"
		systemctl stop 3par.service

		# Removing systemd unit
		printf '%s\t%s\n' "[INF]" "Removing systemd unit"
		rm -rf /etc/systemd/system/3par.service
		systemctl daemon-reload

		# Removing files
		printf '%s\t%s\n' "[INF]" "Removing files"
		rm -rf /etc/3par
		rm -rf /usr/bin/3par
		rm -rf /usr/bin/3par-daemon
		rm -rf /usr/share/man/man1/3par.1.gz

		printf '\n%s\n\n' "3par has been removed"
		;;

	*)
		printf '\n%s\n\n' "Bad option"
		exit 1
		;;
esac

exit 0
