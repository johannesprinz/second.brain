#!/bin/bash

# LDAP credentials
## Prompt for LDAP username
echo -n "Enter LDAP username (e.g., corp\\\\me123): "
read ldap_user

## Prompt for LDAP password
echo -n "Enter LDAP password: "
read -s ldap_password
echo

# Ensure the bin directory exists
mkdir -p ./bin

# Save the credentials to a file
echo "export ldap_user=\"$ldap_user\"" > ./bin/.ldap_credentials
echo "export ldap_password=\"$ldap_password\"" >> ./bin/.ldap_credentials

echo "Setup complete."