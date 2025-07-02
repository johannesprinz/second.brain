#!/bin/bash

# Source the LDAP credentials and configuration
if [ -f ./bin/.ldap_credentials ]; then
    source ./bin/.ldap_credentials
else
    echo "LDAP credentials not found. Please run 'npm run setup' first."
    exit 1
fi

# Validate that all required LDAP configuration is present
if [ -z "$ldap_server" ] || [ -z "$base_dn" ] || [ -z "$ldap_user" ] || [ -z "$ldap_password" ]; then
    echo "LDAP configuration incomplete. Please run 'npm run setup' to configure all required settings."
    echo "Missing: $([ -z "$ldap_server" ] && echo "ldap_server ") $([ -z "$base_dn" ] && echo "base_dn ") $([ -z "$ldap_user" ] && echo "ldap_user ") $([ -z "$ldap_password" ] && echo "ldap_password")"
    exit 1
fi

if [ ! -f ./bin/users.txt ]; then
    echo "User list not found. Please ensure ./bin/users.txt exists."
    exit 1
fi

search_filter="(|"
while IFS= read -r user_id; do
    search_filter="${search_filter}(uid=${user_id})"
done < <(cat ./bin/users.txt | grep -E '^[a-zA-Z0-9]{5}[0-9]{3}$')
search_filter="${search_filter})"

output_file="./bin/ldap.csv"

# Initialize the CSV file with headers
echo "uid,displayName,title,department,employeeType,lastLogon,userAccountControl" > "$output_file"

# Function to convert LDAP timestamp to yyyy-mm-dd format
convert_timestamp() {
    ldap_timestamp=$1
    date -d "@$((ldap_timestamp/10000000-11644473600))" +"%Y-%m-%d"
}

# Read the input file and process each entry
while IFS= read -r line; do
    case $line in
        uid:*)
            uid=$(echo "$line" | cut -d ' ' -f 2)
            ;;
        displayName:*)
            displayName=$(echo "$line" | cut -d ' ' -f 2-)
            ;;
        title:*)
            title=$(echo "$line" | cut -d ' ' -f 2-)
            ;;
        department:*)
            department=$(echo "$line" | cut -d ' ' -f 2-)
            ;;
        employeeType:*)
            employeeType=$(echo "$line" | cut -d ' ' -f 2-)
            ;;
        lastLogon:*)
            lastLogon=$(convert_timestamp $(echo "$line" | cut -d ' ' -f 2))
            ;;
        userAccountControl:*)
            userAccountControl=$(echo "$line" | cut -d ' ' -f 2)
            if [ "$userAccountControl" -eq 512 ]; then
                userAccountControl="active"
            elif [ "$userAccountControl" -eq 514 ]; then
                userAccountControl="disabled"
            fi
            ;;
        "")
            # End of an entry, write to CSV
            if [ -n "$uid" ]; then
                echo "$uid,$displayName,$title,$department,$employeeType,$lastLogon,$userAccountControl" >> "$output_file"
            fi
            # Reset variables for the next entry
            uid=""
            displayName=""
            title=""
            department=""
            employeeType=""
            lastLogon=""
            userAccountControl=""
            ;;
    esac
done < <(ldapsearch -x -H "$ldap_server" -D "$ldap_user" -w "$ldap_password" -b "$base_dn" "$search_filter")

# Check if the ldapsearch command was successful
if [ $? -ne 0 ]; then
    echo "LDAP search failed."
    exit 1
fi
