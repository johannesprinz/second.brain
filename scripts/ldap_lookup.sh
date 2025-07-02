#!/bin/bash

# Source the LDAP credentials
if [ -f ./bin/.ldap_credentials ]; then
    source ./bin/.ldap_credentials
else
    echo "LDAP credentials not found. Please run the setup script first."
    exit 1
fi

# Check if at least one argument (first name) is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <first_name> [last_name]"
    exit 1
fi

# Assign arguments to variables
first_name="$1"
last_name="$2"

# LDAP server and base DN
ldap_server="ldap://corp.ssi.govt.nz"
base_dn="dc=corp,dc=ssi,dc=govt,dc=nz"

# Determine the search filter based on the presence of the last name
if [ -z "$last_name" ]; then
    search_filter="(displayname=$first_name)"
    attributes="mail mobile uid displayname givenName sn title division department l physicaldeliveryofficename employeetype accountexpires whencreated whenchanged lastlogon lastlogontimestamp"
else # Used for troubleshooting and discovering display names
    search_filter="(&(givenName=$first_name)(sn=$last_name))"
    attributes="mail mobile uid displayname givenName sn title division department l physicaldeliveryofficename employeetype accountexpires whencreated whenchanged lastlogon lastlogontimestamp"
fi

# Perform the LDAP search and capture the output
ldap_output=$(ldapsearch -x -H "$ldap_server" -D "$ldap_user" -w "$ldap_password" -b "$base_dn" \
    "$search_filter" $attributes)

# Check if the ldapsearch command was successful
if [ $? -ne 0 ]; then
    echo "LDAP search failed."
    exit 1
fi

# Extract key properties from the first entry
givenName=$(echo "$ldap_output" | grep -m 1 "^givenName:" | cut -d ' ' -f2-)
sn=$(echo "$ldap_output" | grep -m 1 "^sn:" | cut -d ' ' -f2-)
mail=$(echo "$ldap_output" | grep -m 1 "^mail:" | cut -d ' ' -f2-)
mobile=$(echo "$ldap_output" | grep -m 1 "^mobile:" | cut -d ' ' -f2-)
uid=$(echo "$ldap_output" | grep -m 1 "^uid:" | cut -d ' ' -f2-)
displayName=$(echo "$ldap_output" | grep -m 1 "^displayName:" | cut -d ' ' -f2-)
title=$(echo "$ldap_output" | grep -m 1 "^title:" | cut -d ' ' -f2-)
division=$(echo "$ldap_output" | grep -m 1 "^division:" | cut -d ' ' -f2-)
department=$(echo "$ldap_output" | grep -m 1 "^department:" | cut -d ' ' -f2-)
location=$(echo "$ldap_output" | grep -m 1 "^l:" | cut -d ' ' -f2-)
officeName=$(echo "$ldap_output" | grep -m 1 "^physicalDeliveryOfficeName:" | cut -d ' ' -f2-)
employeeType=$(echo "$ldap_output" | grep -m 1 "^employeeType:" | cut -d ' ' -f2-)
whenCreated=$(echo "$ldap_output" | grep -m 1 "^whenCreated:" | cut -d ' ' -f2-)
#whenChanged=$(echo "$ldap_output" | grep -m 1 "^whenChanged:" | cut -d ' ' -f2-)
#lastLogon=$(echo "$ldap_output" | grep -m 1 "^lastLogon:" | cut -d ' ' -f2-)
#lastLogonTimestamp=$(echo "$ldap_output" | grep -m 1 "^lastLogonTimestamp:" | cut -d ' ' -f2-)
#accountExpires=$(echo "$ldap_output" | grep -m 1 "^accountExpires:" | cut -d ' ' -f2-)

# Convert LDAP Generalized Time to human-readable format
convert_ldap_time() {
    ldap_time=$1
    if [[ $ldap_time =~ ^[0-9]{14}\.0Z$ ]]; then
        date -d "${ldap_time:0:4}-${ldap_time:4:2}-${ldap_time:6:2} ${ldap_time:8:2}:${ldap_time:10:2}:${ldap_time:12:2} UTC" +"%Y/%m/%d %H:%M:%S"
    else
        echo "N/A"
    fi
}

# Convert Windows FileTime to human-readable format
#convert_filetime() {
#    filetime=$1
#    if [[ $filetime =~ ^[0-9]+$ ]]; then
#        # Convert 100-nanosecond intervals to seconds
#        seconds=$((filetime / 10000000))
#        # Add seconds to the epoch date (1601-01-01)
#        date -d "1601-01-01 UTC + $seconds seconds" +"%Y/%m/%d %H:%M:%S"
#    else
#        echo "N/A"
#    fi
#}

whenCreatedFormatted=$(convert_ldap_time "$whenCreated")
#whenChangedFormatted=$(convert_ldap_time "$whenChanged")
#lastLogonFormatted=$(convert_filetime "$lastLogon")
#lastLogonTimestampFormatted=$(convert_filetime "$lastLogonTimestamp")
#accountExpiresFormatted=$(convert_filetime "$accountExpires")

echo "| Property             | Value |"
echo "| -------------------- | ----- |"
echo "| Display Name         | $displayName |"
echo "| Given Name / Surname | $givenName / $sn |"
echo "| Title                | $title |"
echo "| Email                | <$mail> |"
echo "| Mobile               | $mobile |"
echo "| UID                  | $uid |"
echo "| Division             | [[division.$division]] |"
echo "| Department           | [[department.$department]] |"
echo "| Office Name          | $officeName |"
echo "| Location             | [[location.$location]] |"
echo "| Employee Type        | $employeeType |"
echo "| When Created         | $whenCreatedFormatted |"        # creates too much change noise
#echo "| When Changed         | $whenChangedFormatted |"        # creates too much change noise
#echo "| Last Logon           | $lastLogonFormatted |"          # creates too much change noise
#echo "| Last Logon Timestamp | $lastLogonTimestampFormatted |" # creates too much change noise
#echo "| Account Expires      | $accountExpiresFormatted |"
