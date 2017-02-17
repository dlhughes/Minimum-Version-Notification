#!/bin/bash

# Assign the minimum version allowed on system and the application to verify. Use no puncuation or symbols in version number.
minimumVersion=127
appname="Google Drive.app"

# verify that parameter 4 has been set
if [ "$4" == "" ]; then
	/bin/echo "Parameter 4 must be set"
	exit 1
fi

# Verify application is installed and get version number. Remove puncuation from version number and assign as variable.
if [ -d /Applications/"$appname" ]; then
	readVersion=$( /usr/bin/defaults read /Applications/"$appname"/Contents/Info.plist CFBundleShortVersionString  2>/dev/null )
	installedVersion=${readVersion//.}
else 
    # Update inventory to descope this system because Google Drive is no longer installed.
	/usr/local/bin/jamf recon
	exit 0
fi

# Compare installed version and minimum bersion. 
if [ "$minimumVersion" -gt "$installedVersion" ]; then
# If Parameter 4 is set to Install call the autoupdate policy.
	if [ "$4" == "Install" ]; then
		/usr/local/bin/jamf policy -event "autoupdate-Google Drive"
		exit 0
# If Parameter 4 is set to Notification, activate the pop up window and awate end user interaction.
	elif [ "$4" == "Notification" ]; then
		/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper -windowType utility -title "OIT Casper" -heading "Google Drive Requires Update" -description "On February 1st 2017 an upgrade to our Google service will cause connection issues for versions of Google Drive under 1.27. The latest version of Google Drive is available via Self Service.app in your Applications folder. Please Contact 1HELP if you need assistance." -icon /Applications/Self\ Service.app/Contents/Resources/Self\ Service.icns -button2 "Self Service" -button1 "Cancel" -defaultButton 2 -cancelButton -1
			if [ "$?" == "2" ]; then
				/usr/bin/open -ga "Self Service.app"
			elif [ "$?" == "0" ]; then
				exit 1
			fi	
	fi
else
	echo "System is above minimum requirement."
fi


exit
