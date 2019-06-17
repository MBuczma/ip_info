#!/bin/bash

#Checking arguments
case $1 in
  -c|--csv)
  CSV=true
  shift
  ;;
  -h|--help)
  echo "Tell me some IP and I tell you more about it"
  echo "-h for help"
  echo "-c for csv format"
  echo "example: ip_info -c 185.33.37.131"
  exit
  ;;
esac


#Setting IP variable. Checking STDIN
if [[ -z "$1" ]] && [[ ! -p /dev/stdin ]]; then
  echo "ERROR: No IP address specified"
  exit
elif [[ -z "$1" ]]; then
  IP=$(cat -)
else
  IP=$1
fi

if [[ $IP == "" ]]; then
  echo "ERROR: No IP address specified"
  exit
fi


#Checking if IP is correct
IpCheck=$(echo $IP | grep -E '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$')
if [[ $IpCheck != $IP  ]] ; then
  echo ERROR: $IP is not a valid IP adress.
  exit
fi


#Using curl to get information about IP
IpApiRespond=`curl --retry 5 -s http://ip-api.com/line/$IP?fields=city,org,as`

if [[ $IpApiRespond == "" ]]; then
  IpApiRespond=`curl --retry 5 -s http://ip-api.com/line/$IP?fields=city,org,as`
fi

if [[ $IpApiRespond == "" ]]; then
  echo -e "\033[1;31m!!!\tERROR: Couldn't connect to ip-api server \t!!!\033[0m"
  exit
else
  Location=$(echo "$IpApiRespond" | awk 'FNR == 1 {print}')
  Organization=$(echo "$IpApiRespond" | awk 'FNR == 2 {print}')
  ASN=$(echo "$IpApiRespond" | awk 'FNR == 3 {print}' | sed 's/ .*//')
fi


#Printing output
if [[ $CSV == true ]] ; then
  echo "$Location;$Organization;$ASN"
else
  echo Location: $Location
  echo Organization: $Organization
  echo ASN: $ASN
fi
