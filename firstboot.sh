#!/bin/bash
# Snowfox Secure Appliances - firstboot.sh script v1.0

echo ""
echo "                                  (((((((((((((                                 "
echo "                  (((((((((((((((((((((((((((((((((((((((((((((                 "
echo "         *(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((,        "
echo "   .(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((   "
echo "  ((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((( "
echo " (((((((((((((((((((((((((((((((((((((((   ((((((((((((((((((((((((((((((((((((."
echo " (((((((((((((((((((((((((((((((((((,     (((((((((((/.((((((((((((((((((((((((("
echo " ((((((((((((((((((((((((((((((((*       *((((((/    /(((((((((((((((((((((((((("
echo " ((((((((((((((((((((((((((((((          (((*       *((((((((((((((((((((((((((("
echo " (((((((((((((((((((((((((((*            (          (((((((((((((((((((((((((((("
echo "(((((((((((((((((((((((((((                        ((((((((((((((((((((((((((((("
echo "(((((((((((((((((((((((((                          ((((((((((((((((((((((((((((("
echo "(((((((((((((((((((((((                      /(.   ((((((((((((((((((((((((((((("
echo "(((((((((((((((((((((*                          .((((((((((((((((((((((((((((((("
echo "((((((((((((((((((((                                 /(((((((((((((((((((((((((("
echo "(((((((((((((((((((                                        ,(((((((((((((((((((("
echo "((((((((((((((((((                                                  //(((((((((("
echo " ((((((((((((((((                                                    ((((((((((("
echo " (((((((((((((((                                                  *((((((((((((("
echo " ((((((((((((((                                           *((((((((((((((((((((."
echo " .(((((((((((((                                    .((((((((((((((((((((((((((( "
echo "  ((((((((((((                                 .((((((((((((((((((((((((((((((, "
echo "   (((((((((((                               ((((((((((((((((((((((((((((((((/  "
echo "   /(((((((((*                            (((((((((((((((((((((((((((((((((((   "
echo "    (((((((((*                          (((((((((((((((((((((((((((((((((((,    "
echo "     ((((((((*                        /(((((((((((((((((((((((((((((((((((*     "
echo "      ,(((((((                       ((((((((((((((((((((((((((((((((((((       "
echo "        ((((((                      (((((((((((((((((((((((((((((((((((/        "
echo "         *((((.                    (((((((((((((((((((((((((((((((((((          "
echo "           ((((                   ((((((((((((((((((((((((((((((((((,           "
echo "             (((                 *((((((((((((((((((((((((((((((((/             "
echo "               ((                ((((((((((((((((((((((((((((((((               "
echo "                 (              .(((((((((((((((((((((((((((((/                 "
echo "                                ((((((((((((((((((((((((((((*                   "
echo "                                ((((((((((((((((((((((((((                      "
echo "                                (((((((((((((((((((((((/                        "
echo "                                (((((((((((((((((((((                           "
echo "                                ((((((((((((((((((                              "
echo "                                 /(((((((((((((,                                "
echo "                                    *(((((((                                    "
echo ""

echo "  _____                      __             ______ _          _   _                 _   "
echo " / ____|                    / _|           |  ____(_)        | | | |               | |  "
echo "| (___  _ __   _____      _| |_ _____  _   | |__   _ _ __ ___| |_| |__   ___   ___ | |_ "
echo " \___ \| '_ \ / _ \ \ /\ / /  _/ _ \ \/ /  |  __| | | '__/ __| __| '_ \ / _ \ / _ \| __|"
echo " ____) | | | | (_) \ V  V /| || (_) >  <   | |    | | |  \__ \ |_| |_) | (_) | (_) | |_ "
echo "|_____/|_| |_|\___/ \_/\_/ |_| \___/_/\_\  |_|    |_|_|  |___/\__|_.__/ \___/ \___/ \__|"
echo ""
echo ""


# ##########################################################################################
# Function to get the MAC address
get_mac_address() {
    # Using the ip command to get the MAC address
    if command -v ip &> /dev/null
    then
        MAC_ADDRESS=$(ip link show | awk '/ether/ {print $2; exit}')
    # Fallback to ifconfig if ip is not available
    elif command -v ifconfig &> /dev/null
    then
        MAC_ADDRESS=$(ifconfig | grep -m 1 ether | awk '{print $2}')
    else
        echo "Neither ip nor ifconfig command is available. Cannot find MAC address."
        exit 1
    fi
}

# Get the MAC address
get_mac_address

# Check if MAC address was successfully retrieved
if [ -z "$MAC_ADDRESS" ]; then
    echo "Failed to retrieve MAC address."
    exit 1
fi

# Echo MAC
echo "MAC Address: " $MAC_ADDRESS

# Request Server ID from the user
read -p "Please enter the Server ID: " SERVER_ID

# Validate Server ID input
if [ -z "$SERVER_ID" ]; then
    echo "Server ID cannot be empty. Please provide a valid Server ID."
    exit 1
fi

SERVER_URL="https://4jiw4icf55.execute-api.us-west-2.amazonaws.com/prod/submit"  # Replace with your server URL

# Create the JSON payload
json_payload="{\"server_id\":\"$SERVER_ID\",\"mac_address\":\"$MAC_ADDRESS\"}"

# Submit the Server ID and MAC address via HTTP POST
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$json_payload" $SERVER_URL)

# # Submit the Server ID and MAC address via HTTP POST
# response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -d "server_id=$SERVER_ID&mac_address=$MAC_ADDRESS" $SERVER_URL)

# Check if the submission was successful
if [ "$response" -eq 200 ]; then
    echo "Done :)"
    # echo "MAC: " $MAC_ADDRESS
    # echo "Server ID: " $SERVER_ID
else
    echo "Submission failed with response code: $response"
    echo "MAC: " $MAC_ADDRESS
    echo "Server ID: " $SERVER_ID
fi
    