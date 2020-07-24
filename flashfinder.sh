#!/bin/bash
############################################################################
#flashfinder.sh  (find instances of Adobe Flash on website)                #
#version 1.0                                                               #
# by Ely Pinto technicalciso.com                                           #
############################################################################

APIKEY="" #your google api key here
CXID="" #your google search engine ID here
FLASHTEXT="%20flash%20player" #search text for Flash, other options exist

set -a
CURL="/usr/bin/curl -s"
GREP=/usr/bin/grep
CUT=/usr/bin/cut
SED=/usr/bin/sed
XARGS=/usr/bin/xargs

#no more changes
function confirmlink {
        $CURL $1 | $GREP -i swf > /dev/null 2>&1 && echo "flash confirmed: $1" || echo "flash not found (could be old cache): $1"
}
set +a

if [ ! "$1" ]
then
        echo "Usage: $0 <site>"
        exit 1
elif  [[ "$1" =~ " " ]] #spaces break our curl #TODO
then
        echo "Spaces not allowed in site"
        exit 1
fi

QURL="https://www.googleapis.com/customsearch/v1?key=$APIKEY&cx=$CXID&q=site:$1:$FLASHTEXT"
$CURL $QURL | $GREP "\"link\"" | $CUT -d":" -f2- | $SED -e "s/,$//" | $XARGS -I@ bash -c "$(declare -f confirmlink) ; confirmlink @ ;"
