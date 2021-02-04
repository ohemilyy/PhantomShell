WHICHID=$(ls /usr/bin/ | grep which)
VERSION="1.1.0-production"
which awk > /dev/null
AWKID=$?
which curl > /dev/null
CURLID=$?
which dos2unix > /dev/null
DOSUNIXID=$?
OSID=$(/usr/bin/env awk -F= '/^NAME/{print $2}' /etc/os-release)

if (( $EUID != 0 )); then
    echo "Please run the Artemis Shell deployment script as superuser (NO SUDO!)."
    exit 1
fi

if [ $OSID != '"Ubuntu"' ]; then
    echo "This script can only be used with Ubuntu-based systems."
    exit 1
fi

if (( $CURLID != 0 )); then
    echo "Install curl to /usr/bin/curl, then try again."
    exit 1
fi

if (( $DOSUNIXID != 0 )); then
    echo "Install dos2unix to /usr/bin/dos2unix, then try again."
    exit 1
fi

if (( $AWKID != 0 )); then
    echo "Install awk to /usr/bin/awk, then try again."
    exit 1
fi

if (( $WHICHID != "which" )); then
    echo "Install which to /usr/bin/which, then try again."
    exit 1
fi

/usr/bin/env echo "Thank you for using Artemis Shell!"
/usr/bin/env echo "Artemis Shell is a set of modifications that extend and modify Bash. It extends Bash's abilities and customises the style of Bash to reflect Artemis branding guidelines."
/usr/bin/env echo "It also modifies CommandNotFound, MOTD, and the SSH banner to reflect that of Artemis infrastructure guidelines."
/usr/bin/env echo "The MOTD will also be modified so it points to motd.artemis.org.uk, delivering infrastructure-specific announcements."
read -p "Are you sure you want to continue? This may damage your system. [Y/n] " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    # Create artemisctl directory
    mkdir -p /etc/artemisctl
    # Add version to /etc/artemisctl/version
    echo "$VERSION" > /etc/artemisctl/version
    # Clean all files
    /usr/bin/env rm -rf /etc/update-motd.d/*
    /usr/bin/env rm -rf /etc/banner
    /usr/bin/env rm -rf /etc/profile
    /usr/bin/env rm -rf /etc/bash.bashrc
    /usr/bin/env rm -rf /usr/bin/version
    /usr/bin/env rm -rf /usr/lib/command-not-found
    /usr/bin/env rm -rf /etc/skel/.bashrc
    /usr/bin/env rm -rf /usr/lib/python3/dist-packages/CommandNotFound/CommandNotFound.py
    /usr/bin/env mkdir -p /var/cache/motd-news.d/
    # Download assets
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/update-motd.d/00-introduction --output /etc/update-motd.d/00-introduction
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/update-motd.d/10-header --output /etc/update-motd.d/10-header
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/update-motd.d/20-help-text --output /etc/update-motd.d/20-help-text
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/update-motd.d/50-motd-news --output /etc/update-motd.d/50-motd-news
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/etc/banner --output /etc/banner
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/profile --output /etc/profile
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/bash.bashrc --output /etc/bash.bashrc
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/command-not-found/usr-lib/command-not-found --output /usr/lib/command-not-found
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/command-not-found/usr-lib/python3-distpkgs/CommandNotFound.py --output /usr/lib/python3/dist-packages/CommandNotFound/CommandNotFound.py
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/skel/.bashrc --output /etc/skel/.bashrc
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/commands/version --output /usr/bin/version
    # Update permissions
    /usr/bin/env chmod +x /etc/update-motd.d/*
    /usr/bin/env chmod +x /usr/bin/version
    # Convert all files from Windows to Unix format
    /usr/bin/dos2unix /etc/skel/.bashrc > /dev/null
    /usr/bin/dos2unix /etc/update-motd.d/* > /dev/null
    /usr/bin/dos2unix /usr/bin/version > /dev/null
    /usr/bin/dos2unix /usr/lib/python3/dist-packages/CommandNotFound/CommandNotFound.py > /dev/null
    /usr/bin/dos2unix /usr/lib/command-not-found > /dev/null
    /usr/bin/dos2unix /etc/bash.bashrc > /dev/null
    /usr/bin/dos2unix /etc/profile > /dev/null
    /usr/bin/dos2unix /etc/banner > /dev/null
else
  exit 0
fi

read -p "Does this machine support Authenticator 2FA logins? [Y/n] " prompttwo
if [[ $prompttwo == "y" || $prompttwo == "Y" || $prompttwo == "yes" || $prompttwo == "Yes" ]]
then
    /usr/bin/env rm -rf /etc/ssh/sshd_config
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/etc/ssh/sshd_config-2fa --output /etc/ssh/sshd_config
    /usr/bin/dos2unix /etc/ssh/sshd_config > /dev/null
else
    /usr/bin/env rm -rf /etc/ssh/sshd_config
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/etc/ssh/sshd_config-n2fa --output /etc/ssh/sshd_config
    /usr/bin/dos2unix /etc/ssh/sshd_config > /dev/null
fi

# Download Artemis Updater
echo "Installing Artemis Updater.."
/usr/bin/env rm -rf /usr/bin/artemis-updater
/usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/commands/artemis-updater --output /usr/bin/artemis-updater
/usr/bin/env chmod +x /usr/bin/artemis-updater
/usr/bin/dos2unix /usr/bin/artemis-updater > /dev/null

read -p "Artemis Shell has been installed. Press any key to exit.. "
exit 0