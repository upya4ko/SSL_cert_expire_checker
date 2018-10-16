#!/bin/bash

## cert exp date checker by McPcholkin
## based on https://www.zabbix.com/forum/showthread.php?t=755 by jpawlowski 
## and https://www.appliedtrust.com/blog/2011/11/keep-an-eye-on-those-certificate-expiration-dates

DATE=`which date`
OPENSSL=`which openssl`
HOST=$1
PORT=$2
DEBUG='false'

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


if [ $DEBUG == 'true' ]
  then
    echo "----------------------------"
    echo "        Debug enabled"
    echo "----------------------------"
    echo ""
    echo "Openssl path - $OPENSSL"
    echo "Date path - $DATE"
    echo "Check host - $HOST"
    echo "Check port - $PORT"
    echo ""
fi

# Get Cert from host
# Get string "notAfter" from cert
# Trim string "notAfter" and get date in format "Aug 13 12:24:00 2017 GMT"
CertEndDate=`echo "" \
    | $OPENSSL s_client -connect $HOST:$PORT 2>/dev/null \
    | $OPENSSL x509 -enddate -noout 2>/dev/null \
    | sed 's/notAfter\=//'`

if [ $DEBUG == 'true' ]
  then
    echo "Cert exp date - $CertEndDate"

    # Debug  Convert cert exp date to "date --date now" format 
    echo "Cert exp date in \"date --date now\" format - $(date --date "$CertEndDate")" 
    echo ""
fi

# Convert "date --date now" format to seconds after UNIXTIME
CertEndDateSec=`$DATE --date "$CertEndDate" +%s`

if [ $DEBUG == 'true' ]
  then
    echo "Cert exp date in seconds (UNIXTIME) - $CertEndDateSec"
    echo ""
fi

# current date in seconds UNIXTIME
CurrentDate=`$DATE --date now  +%s`

if [ $DEBUG == 'true' ]
  then
    echo "Current date in seconds (UNIXTIME) - $CurrentDate"
    echo ""
fi

# End date minus Curent date
DiffSeconds=$(($CertEndDateSec - $CurrentDate))

if [ $DEBUG == 'true' ]
  then
    echo "Diff in seconds - $DiffSeconds"
    echo ""
fi

DiffDays=$(($DiffSeconds/86400))

if [ $DEBUG == 'true' ]
  then
    echo "Diff in days - $DiffDays"
    echo ""
    echo "------------------------------"
    echo ""
fi

# Actual output
if [ $DEBUG != 'true' ]
  then
    echo "$DiffDays"
fi


if [ $DEBUG == 'true' ]
  then
    if [ $DiffDays == 0 ]
      then
        echo "Cert expired or wrong address"
        exit 1
    else
      if [ $DiffDays -le 2 ]
        then      
          echo "Alert! left $DiffDays days to renew cert"
       elif [ $DiffDays -le 10 ]
          then
            echo "Alert! left $DiffDays days to renew cert"
        elif [ $DiffDays -gt 10 ]
          then
            echo "All Ok Cert will be valid next $DiffDays days"
        fi
 fi
echo ""
fi

