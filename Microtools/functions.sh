#!/bin/bash


# Invalid Selection in Menus
invalidselection () {
        clear
        echo "You have entered an invalid selection!"
        echo "Please try again!"
        echo ""
        echo "Press any key to continue..."
        read -n 1
}

# Q q - Press Q to Quit
quitscript () {
        clear
        exit 0
}

# Get OS information.
variables () {

        #LSB Release is not included by default in Debian 9. Workaround Incoming.
        #OS=$(lsb_release -si)

        ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')

        #LSB Release is not included by default in Debian 9. Workaround Incoming.
        #VER=$(lsb_release -sr)

        #OSST=$OS" "$VER
        LOCALIP=$(ip a | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

        #Still Broke, Plz Fix.
        #RANDSTRING=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

        # Get script information
        SCRIPT=$(readlink -f "$0")
        DIR=$(dirname "$SCRIPT")  
}

# Server Info: displays information about server.
information () {
        echo "NOTE: If IP isn't visible, the formatting of one or more scripts is causing problems."
        echo ""
        echo "OS:			                "$OSST
        echo "Architecture:				"$ARCH
        echo "IP Address:				"$LOCALIP
        echo ""
        echo "Script Location:				"$SCRIPT
        echo ""
}

warning () {
        echo "                     -----=====WARNING=====-----"
        echo "The most common reason for any part of this script failing is formatting."
        echo "           Putty, WSL and other such emulators wrap lines."
        echo " Paste this script into a fullscreen terminal or it *will* break things."
        echo "					   Press any key to continue..."
        read -n 1
}

exit 0
