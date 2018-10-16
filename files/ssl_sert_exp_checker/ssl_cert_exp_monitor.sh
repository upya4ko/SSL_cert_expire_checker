#!/bin/bash

## cert end date checker by McPcholkin
## based on https://www.zabbix.com/forum/showthread.php?t=755 by jpawlowski 
## and https://www.appliedtrust.com/blog/2011/11/keep-an-eye-on-those-certificate-expiration-dates

DATE=`which date`
OPENSSL=`which openssl`
HOST=$1
PORT=$2

if [ $# == 0 ]   # check if any argument exist
   then         # show help
        echo "No arguments"
        echo
        echo "Usage: host port or just host (default 443 port)"
        echo "       $0 example.com 443"
        echo "   or  $0 example.com"
        echo
        exit 1
    elif [ $#  == "1" ]
        then
        PORT="443"     
fi

# Debug
#echo $OPENSSL
#echo $DATE
#echo $HOST
#echo $PORT
#

                  # Get Cert from host
                  # Get string "notAfter" from cert
                  # Trim string "notAfter" and get date in format "Aug 13 12:24:00 2017 GMT"
CertEndDate=`echo "" \
    | $OPENSSL s_client -connect $HOST:$PORT 2>/dev/null \
    | $OPENSSL x509 -enddate -noout 2>/dev/null \
    | sed 's/notAfter\=//'`

# Debug
#echo "$CertEndDate"

# Debug  Convert cert exp date to "date --date now" format 
#echo "$(date --date "$CertEndDate")" 

# Debug  Convert "date --date now" format to seconds after UNIXTIME
#echo "$(date --date "$CertEndDate"  +%s)"

# Convert "date --date now" format to seconds after UNIXTIME
CertEndDateSec=`$DATE --date "$CertEndDate" +%s`

# Debug
#echo "$CertEndDateSec Cert end date in sec"

# current date in seconds UNIXTIME
CurrentDate=`$DATE --date now  +%s`

#Debug
#echo "$CurrentDate Current date in seconds"

# End date minus Curent date
DiffSeconds=$(($CertEndDateSec - $CurrentDate))

# Debug
#echo "$DiffSeconds Diff in seconds"

DiffDays=$(($DiffSeconds/86400))

#echo "$DiffDays Diff in days"
 

#echo
#echo -----------------------------------
#echo

#DiffDays=1


echo "$DiffDays"


#
#if [ $DiffDays == 0 ]
#    then
#        echo "Cert expired or wrong address"
#        exit 1
#    else
#      if [ $DiffDays -le 2 ]
#        then      
#          echo "Alert! left $DiffDays days to renew cert"
#       elif [ $DiffDays -le 10 ]
#          then
#            echo "Alert! left $DiffDays days to renew cert"
#        elif [ $DiffDays -gt 10 ]
#          then
#            echo "All Ok Cert whill be valid next $DiffDays days"
#        fi
# fi
#
#

