#!/bin/sh

# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.


#################################################################################
#
#Script: get-ld-members.sh
#Purpose : get all distribution with members
#
#CHANGE LOG
#2013-03-07 / updated for the new Zimbra8 install
#
################################################################################

VERSION=3
###########################
# VARIABLES
###########################

_OUTPUT=/tmp/x-gdl-content.txt
_LD=/tmp/x-gadl.txt

DOMAIN=(domain.ch)
MY_DATE="$(date +"%Y-%m-%d_%H%M")"
SERVER="ZIMBRA-01.lan"
ZMAILSERVER=10.1.92.31
ZMAILFROM='<admin@zimbra.lan>'
ZMAILTO=(admin@domain.ch)
ZPORT=25
ZSIGNATURE='Sent by the script "get-ld-members.sh" version '$VERSION'  2013-03-07'


###########################
# MAIN SCRIPT PART 
###########################

ELEMENTS_DOMAIN=${#DOMAIN[@]}

for (( DOM=0;DOM<$ELEMENTS_DOMAIN;DOM++)); do

_LD=/tmp/gdl-list-${DOMAIN[${DOM}]}.txt
_OUTPUT=/tmp/gdl-content-${DOMAIN[${DOM}]}.txt


zmprov gadl | grep ${DOMAIN[${DOM}]} > $_LD 

cat /dev/null > $_OUTPUT
cat $_LD | \
while read LINE; do
zmprov gdl $LINE | sed 's/^zimbraMailForwardingAddress: //g' | sed '/^objectClass:/d' | sed '/^uid:/d' | sed '/^cn:/d' | sed '/^mail:/d' >> $_OUTPUT
done

###########################
# sending email
###########################
echo "Sending email"

ELEMENTS=${#ZMAILTO[@]}

for (( i=0;i<$ELEMENTS;i++)); do
# Establish connection
echo
echo "Connecting to $ZMAILSERVER on Port $ZPORT";
echo "Please wait ... "
echo
exec 3<>/dev/tcp/$ZMAILSERVER/$ZPORT

if [ $? -ne 0 ] ; then
echo
echo "ERROR: Cannot connect to the Mail Server";
echo "Please check the servername and/or the port number"
exit
fi

sleep 1
echo -en "HELO ZIMBRA-01.lan\r\n">&3
#echo -en "HELO ZIMBRA-01.lan\r\n">&2

sleep 1
echo -en "MAIL FROM:"$ZMAILFROM"\r\n" >&3
#echo -en "MAIL FROM:"$ZMAILFROM"\r\n" >&2

sleep 1
echo -en "RCPT TO:"${ZMAILTO[${i}]}"\r\n" >&3
#echo -en "RCPT TO:"${ZMAILTO[${i}]}"\r\n" >&2

sleep 1
echo -en "DATA\r\n" >&3
#echo -en "DATA\r\n" >&2

echo -en "Date: $(date)\r\n" >&3
#echo -en "Date: $(date)\r\n" >&2

echo -en "From: \"Zimbra Distribution List Members \" "$ZMAILFROM"\r\n" >&3
#echo -en "From: \"Zimbra Distribution List Members\" "$ZMAILFROM"\r\n" >&2

echo -en "To: "${ZMAILTO[${i}]}"\r\n" >&3
#echo -en "To: "${ZMAILTO[${i}]}"\r\n" >&2

echo -en "Subject: $1 Distribution List  Members from ${DOMAIN[${DOM}]} ("$SERVER")\r\n" >&3
#echo -en "Subject: $1 Distribution List Members from ${DOMAIN[${DOM}]} ("$SERVER")\r\n" >&2

cat $_OUTPUT >&3
echo -en ".\r\n" >&3

sleep 1
echo -en "QUIT\r\n" >&3

sleep 1
cat <&3 >&2
done

done

echo "END"
###########################
# end
###########################

