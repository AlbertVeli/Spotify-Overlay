#!/bin/sh

# Create a file called credentials.txt and put the following lines in it
# If you want to send an e-mail when a new version is available.
# Change to your credentials of course.
#
# MAILTO=myown@email.com
# MAILFROM=me@home
# SMTPSERVER=my.smtpserver.com

if [ -f credentials.txt ]; then
	source credentials.txt
fi

# Check latest version. This assumes only the latest .deb is available in the spotify dir
# which has been safe so far. Spotify always seems to remove old versions when they upload a new version.
f=`curl http://repository.spotify.com/pool/non-free/s/spotify/ 2>/dev/null | sed -n 's/^.*>\(spotify-client-qt_.*_i386.deb\).*/\1/p'`
# Sed out version number
ver=`echo $f | sed 's/^.*_\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\).*/\1/'`
# And hash
hash=`echo $f | sed 's/^.*\.\(.*\)-1_i386.deb/\1/'`

# Get my latest local version
myver=`ls -th spotify-* | head -1 | sed -n 's/spotify-\(.*\).ebuild/\1/p'`

# Compare version on server with my local version
if [ "$ver" = "$myver" ]; then
	echo "Got latest version ($ver)"
	exit 0
fi

# New version is available.
# cat spotify-0.4.7.132 which has hash g9df34c0 and replace
# with new hash, redirect output to new version ebuild.
cat spotify-0.4.7.132.ebuild | sed "s/g9df34c0/$hash/" > spotify-$ver.ebuild

echo "New version \"$ver\" available (got \"$myver\")"

# Send out an email to remind me that a new version is available (if credential.txt exists).
if [ -f credentials.txt ]; then
	sendEmail -f $MAILFROM -s $SMTPSERVER -u "Spotify $ver available" -t $MAILTO -m "New Spotify $ver available. Update overlay."
fi

