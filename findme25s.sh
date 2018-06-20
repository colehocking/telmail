#!/bin/bash

# Find open port 25s on a network. 
# Requires: masscan
# run `sudo apt-get install masscan` on debian-based systems
#   -- Cole Hocking

# The default scan range for masscan
RATE=1000000

# Introduction text output
intro() { 
    echo -e "\nLet's find some open port 25s!"
    echo "(requires: masscan tool)"
    echo "outputs results to ./results/open25s.txt"
}

# Obtain IPv4 range from user
get_range(){
    echo -e "\nEnter an IPv4 net range or CIDR block:"
    read -p '> ' IP_RANGE
}

# Change scan rate if user requests
rate_change(){
    echo -e "\nEnter the scan rate in packets per second:"
    read -p '> ' RATE
}

# Ask user if they want to change the scan rate
prompt_rate_change(){
    echo -e "\nDo you want to change the default scan rate of 100000 packets/sec?"
    echo "This should be fine for most standard processors."
    select change_rate in "Yes" "No"; do
        case $change_rate in
            "Yes" ) rate_change; break;;
            "No" ) break;;
        esac
    done
}

# Conduct the scan; output results
# Old results will be written over
scan_range(){
    echo -e "\nScanning range for open port 25s"
    masscan -p25 $IP_RANGE --rate=$RATE | grep Discovered | awk '{print $6}'| tee ./results/open25s.txt
    echo "Done! List of IPs in './results/open25s.txt'"
}

# main method to call others
main() {
    intro
    get_range
    prompt_rate_change
    scan_range
}
main
