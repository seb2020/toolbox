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
#Script: accountusage
#Purpose : get account usage
#
#CHANGE LOG
#2013-04-22 / Script creation for zimbra 8
#
################################################################################

APP="get_account_usage.sh"
VERSION="3 -- "
###########################
# VARIABLES
###########################

COS_ENT='enterprise]'
COS_FREE='free]'
COS_PRO='pro]'
COS_STD='standard]'

SERVER=zimbra-01.lan

###########################
# Variable pas besoin de retoucher

MY_DATE="$(date +"%Y-%m-%d")"
MY_TIME="$(date +"%H%M")"

OUTPUT="/tmp/zimbra_users_report/"$MY_DATE".log"
OUTPUT_TMP_DIR="/tmp/zimbra_users_report/"
OUTPUT_SIZE="/scripts/output/zimbra_users_report"$MY_DATE"_size.txt"
OUTPUT_DONE="/scripts/output/zimbra_users_report-$(hostname).txt"

PAD=$(printf '%0.1s' " "{1..60})
PAD_CUSTOMER=30
PAD_DATE=13
PAD_TIME=8
PAD_ENTRY=15
###########################

mkdir -p $OUTPUT_TMP_DIR
rm -f $OUTPUT
touch $OUTPUT

if [ ! -e "$OUTPUT_DONE" ] ; then
    # echo " file does not exists :  writing header "
    echo '============================================================================================================================= '  >> $OUTPUT_DONE
    echo '=== DATE   | TIME  | CUSTOMER                    | Enterprise   | Pro          | Standard     | Free-of-charge | Size' >> $OUTPUT_DONE
    echo '============================================================================================================================= ' >> $OUTPUT_DONE
    echo "" >> $OUTPUT_DONE
  else
    echo "" >> $OUTPUT_DONE
  fi


for DOM in $(/opt/zimbra/bin/zmprov gad | grep -v zimbra.lan | grep -v test  | grep -v domaine.ch )
  do

  ###########################
  # Generating Data
  ###########################

  OUTPUT_DOMAIN=$DOM
  rm -f $OUTPUT_DOMAIN
  touch $OUTPUT_DOMAIN

  OUTPUT_DOMAIN_DONE=$OUTPUT_DOMAIN".log"
  rm -f $OUTPUT_DOMAIN_DONE
  touch $OUTPUT_DOMAIN_DONE


  /opt/zimbra/bin/zmprov gqu $SERVER | grep $DOM | grep -v "galsync@"| awk {'print $3" "$2" "$1'} | while read line
    do
    USAGE=`echo $line|cut -f1 -d " "`
    QUOTA=`echo $line|cut -f2 -d " "`
    USR=`echo $line|cut -f3 -d " "`
    USAGE_VAL=`expr $USAGE / 1024 / 1024`
    QUOTA_VAL=`expr $QUOTA / 1024 / 1024`

    USAGE_TOT=$(( USAGE_VAL + USAGE_TOT ))
	
    COS_ID=$(zmprov ga $USR | grep zimbraCOSId | awk {'print $2'})
    COS_NAME=$(zmprov gc $COS_ID | grep cn: | sed 's/cn: //g'| sed "s/$DOM//g")

    printf '%s%*.*s%s%*.*s%s' "$USR" 0 $(($PAD_USER - ${#USR} )) "$PAD" " Cos=$COS_NAME" 0 $(($PAD_COS - ${#COS_NAME} +4 ))  "$PAD" " $USAGE_VAL Mb" >> $OUTPUT_DOMAIN

    if [ $QUOTA -gt 0 ] ; then
      VAL=$(( USAGE * 100 ))
      VAL=$(( VAL / QUOTA ))
      echo " Quota: $VAL % (Max=$QUOTA_VAL Mb) " >> $OUTPUT_DOMAIN
    else
      printf '\n' >> $OUTPUT_DOMAIN
    fi

    echo "$USAGE_TOT" > $OUTPUT_SIZE
  done # zmprov gqu

  ###########################
  # Sorting
  ###########################

  COUNT_ENT=$(grep -c $COS_ENT $OUTPUT_DOMAIN )
  COUNT_FREE=$(grep -c $COS_FREE $OUTPUT_DOMAIN )
  COUNT_PRO=$(grep -c $COS_PRO $OUTPUT_DOMAIN )
  COUNT_STD=$(grep -c $COS_STD $OUTPUT_DOMAIN )
  COUNT_SIZE=`cat $OUTPUT_SIZE`

  printf '%s%*.*s' "$MY_DATE" 0 $(($PAD_DATE - ${#MY_DATE} )) "$PAD" >> $OUTPUT_DONE
  printf '%s%*.*s' "$MY_TIME" 0 $(($PAD_TIME - ${#MY_TIME} )) "$PAD" >> $OUTPUT_DONE
  printf '%s%*.*s' "$DOM" 0 $(($PAD_CUSTOMER - ${#DOM} )) "$PAD" >> $OUTPUT_DONE
  printf '%s%*.*s' "$COUNT_ENT" 0 $(($PAD_ENTRY - ${#COUNT_ENT} )) "$PAD" >> $OUTPUT_DONE 
  printf '%s%*.*s' "$COUNT_PRO" 0 $(($PAD_ENTRY - ${#COUNT_PRO} )) "$PAD" >> $OUTPUT_DONE 
  printf '%s%*.*s' "$COUNT_STD" 0 $(($PAD_ENTRY - ${#COUNT_STD} )) "$PAD" >> $OUTPUT_DONE 
  printf '%s%*.*s' "$COUNT_FREE"  0 $(($PAD_ENTRY - ${#COUNT_FREE} )) "$PAD" >> $OUTPUT_DONE 
  echo "$COUNT_SIZE MB" >> $OUTPUT_DONE
              
done  # DOM
			  
echo "END"
###########################
# end
###########################


