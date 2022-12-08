#!/bin/bash
############################################################################
#neganews.sh  (find negative news about a company)	                   #
#version 1.2 (Dec 2022) / original Dec 2022                                #
# by Ely Pinto technicalciso.com                                           #
############################################################################

#LIMITATIONS################################################################
#not a substitute for commercial AML/KYC/CFT tools			   #
#limited # of keywords available as they are passed into the query URL     #
#spaces in keywords will be treated as separate keywords		   #
#the JSON API will never return more than 100 results per query		   #
#each iteration (e.g. 10 queries to get 100 results) counts as a query     #
############################################################################


CXID="013493974029350863363:yf94pmgzwvf" #your google programmable search engine ID here
APIKEY="AIzaSyAAM4FWl_jPpGzZdz6tgJJVwWx1uAUNbPs" #your google custom search API key here

#TODO: iterate up to 100 results - need to test
#TODO: check for error codes 

#google config 
gconfig="dateRestrict=d2&sort=date&tbm=nws" #two days old only, sort by date (newest first), restrict to news

set -a
CURL="/usr/bin/curl -s"
GREP=/usr/bin/grep
CUT=/usr/bin/cut
SED=/usr/bin/sed
TEE=/usr/bin/tee
XARGS=/usr/bin/xargs

#no more changes
set +a
API_RESULT_LIMIT=100 #current google JSON API limit
API_NUM=10 #max num of results per page

while getopts c:k:m:l: flag
do
    case "${flag}" in
        c) companynames_file=${OPTARG};;
        k) keywords_file=${OPTARG};;
        m) max_results=${OPTARG};;
        l) log_file=${OPTARG};;
    esac
done

if [ -z "$companynames_file" ] || [ -z "$keywords_file" ]
then
	echo "Usage: $0 -c <companynames_file> -k <keywords_file> [-m max_results] [-l logfile]"
	exit 1
fi

if [ ! -s "$companynames_file" ] 
then
	echo "$companynames_file not found or empty."
	exit 1
fi

if [ ! -s "$keywords_file" ] 
then
	echo "$keywords_file not found or empty."
	exit 1
fi

if [ ! -z "$max_results" ]
then 
	case $max_results in
    	*[!0-9]*) echo "max_results must be numeric" & exit 1 ;;
    	*) ;;
	esac
	[ "$max_results" -eq 0 ] && echo "Warning: max_results not specified, defaulting to $API_RESULT_LIMIT" && max_results=$API_RESULT_LIMIT
	[ "$max_results" -gt "$API_RESULT_LIMIT" ] && echo "max_results cannot exceed API limit, setting to $API_RESULT_LIMIT" && max_results=$API_RESULT_LIMIT
else
	echo "Warning: max_results not specified, defaulting to $API_RESULT_LIMIT" && max_results=$API_RESULT_LIMIT
fi

#start
echo "loading keywords"
orTerms=""
while read -r keyword
do
	[ ! -z "$keyword"  ] && orTerms="$orTerms$keyword "
done <"$keywords_file"

orTerms=${orTerms::-1} #delete the trailing space
orTerms=${orTerms// /%20} #convert spaces in the search URL

while read -r name 
do
	num=$API_NUM
	[ ! -z "$name"  ] && name=${name// /%20} && echo "searching $name" #convert spaces in the search URL
	
	QURL="https://www.googleapis.com/customsearch/v1?key=$APIKEY&cx=$CXID&$gconfig&exactTerms=$name&orTerms=$orTerms&fields=queries(request(totalResults))"
	totalResults=$($CURL $QURL | $GREP -m1 totalResults | $CUT -d \" -f4) 
	echo -n "total results: $totalResults, "
	[ -z "$totalResults" ] || [ "$totalResults" -eq 0 ] && echo "displaying: 0" && echo && continue #nothing to see here
	[ "$totalResults" -gt "$max_results" ] && totalResults=$max_results
	echo "displaying: $totalResults"	

	start=1
	while [ "$start" -le $(($totalResults)) ]
	do
		QURL="https://www.googleapis.com/customsearch/v1?key=$APIKEY&cx=$CXID&$gconfig&exactTerms=$name&orTerms=$orTerms&start=$start&num=$num"
		[ ! -z "$log_file" ] && LOGME="$TEE -a $log_file " || LOGME="$TEE /dev/null" #tricksy but ugly. it works
		$CURL $QURL | $LOGME | $GREP "\"link\"" | $CUT -d":" -f2- | $SED -e "s/,$//"
		start=$(($start + $API_NUM))
		[ "$(($start + $API_NUM))" -gt "$totalResults" ] && num=$((1+$API_NUM-(($(($start + $API_NUM))-$totalResults))))
	done
	echo
done <"$companynames_file"

exit 0
