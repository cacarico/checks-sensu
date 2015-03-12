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

site=$1
warning=$2
critical=$3

trans_uni(){
   case $1 in
        Fev) echo "Feb";;
        Abr) echo "Apr";;
        Mai) echo "May";;
        Ago) echo "Aug";;
        Set) echo "Sep";;
        Out) echo "Oct";;
        Dez) echo "Dec";;
        *)   echo $1;;
   esac
}

calc_data() {
   d1=$(date -d "$1" +%s)
   d2=$(date -d "$2" +%s)
   rem_day=`echo $(( (d1 - d2) / 86400))`
   if [ $rem_day -le 0 ]; then
      rem_day=`echo $(( (d1 - d2) / 86400)) | sed 's/-//g'`
      echo "Critical - Certificado expirado a $rem_day dias" && exit 2
   fi
   rem_day=`echo $(( (d1 - d2) / 2592000))`
   return $rem_day
}

# Dados do vencimento
data_vence=`echo | openssl s_client -connect $1:443 2>/dev/null | openssl x509 -noout -dates | grep 'notAfter' | sed 's/=/ /g' | awk {' print $3" "$2" "$5 '}`

# Dados atuais
mes_atual=`date | awk {' print $2 '}`
mes_atual=`trans_uni $mes_atual`
dia_atual=`date | awk {' print $3 '}`
ano_atual=`date | awk {' print $6 '}`

data_atual="$dia_atual $mes_atual $ano_atual"

calc_data "$data_vence" "$data_atual"
fal_mes=$?

if [ $fal_mes -le $critical ]; then echo "Critical - $site $fal_mes mes restante" && exit 2; fi
if [ $fal_mes -le $warning ]; then echo "Warning - $site $fal_mes meses restantes" && exit 1; fi
echo "OK = $site $fal_mes meses restantes"; exit 0
