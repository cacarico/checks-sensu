#! /bin/bash
#
# Checks SSL time until certificates expires...
#
#
# DESCRIPTION:
# This script curls urls and checks how time is left until ir expires.
#
# OUTPUT:
# Text and exit level
#
# PLATFORMS:
# Linux
#
# DEPENDENCIES:
# Curl
#
# LICENSE:
# Copyright 2014 Yieldbot, Inc <devops@yieldbot.com>
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.
#
# AUTHOR:
# Caio Quinilato Teixeira 
# cqteixeira@live.com
# https://github.com/cqteixeira
#
# Entries:
# check-ssl.sh <site url> <months left to warning> <months left to critical>


url=$1
warning=$2
critical=$3

# Depending what country you live your date can be in other lenguage diferent from english.
trans_uni(){
   case $1 in
        Jan) echo 'Jan';;
        Fev) echo 'Feb';;
	Mar) echo 'Mar';;
        Abr) echo 'Apr';;
        Mai) echo 'May';;
	Jun) echo 'Jun';;
	Jul) echo 'Jul';;
        Ago) echo 'Aug';;
        Set) echo 'Sep';;
        Out) echo 'Oct';;
	Nov) echo 'Nov';;
        Dez) echo 'Dec';;
        *)   echo 'Month entry is wrong!'; exit 3;;
   esac
}

calc_date() {
   d1=$(date -d "$1" +%s)
   d2=$(date -d "$2" +%s)
   rem_day=`echo $(( (d1 - d2) / 86400))`
   if [ $rem_day -le 0 ]; then
      rem_day=`echo $(( (d1 - d2) / 86400)) | sed 's/-//g'`
      echo "Critical - SSL expired $rem_day days ago" && exit 2
   fi
   rem_day=`echo $(( (d1 - d2) / 2592000))`
   return $rem_day
}

# Dados do vencimento
expire_month=`echo | openssl s_client -connect $1:443 2>/dev/null | openssl x509 -noout -dates | grep 'notAfter' | sed 's/=/ /g' | awk {' print $3" "$2" "$5 '}`

# Dados atuais
current_month=`date | awk {' print $2 '}`
current_month=`trans_uni $current_month`
current_day=`date | awk {' print $3 '}`
current_year=`date | awk {' print $6 '}`

current_date="$current_day $current_month $current_year"

calc_date "$expire_month" "$current_date"
months_left=$?

if [ $months_left -le $critical ]; then echo "Critical - $url $months_left months left" && exit 2; fi
if [ $months_left -le $warning ]; then echo "Warning - $url $months_left months left" && exit 1; fi
echo "OK = $url $months_left months left"; exit 0
