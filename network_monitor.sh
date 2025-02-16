#!/bin/bash

LANG=C

# External server to monitor (e.g., Google DNS server)
SERVER="8.8.8.8"

# Log file location
# LOG_FILE="/var/log/network_monitor.log"
LOG_FILE="./network_monitor.log"

# Email notification (optional)
EMAIL="youremail@example.com"

# Ping interval (in seconds)
PING_INTERVAL=20

# Maximum allowed failed attempts before sending an email
MAX_FAILURES=3

# Counter for consecutive failed pings
FAILURE_COUNT=0

# Function to ring bell
ring_bell() {
    times_to_ring=$1
    for n in $(seq 1 $times_to_ring);do
	tput bel
	sleep 0.1
    done
}

# Function to send email notification
send_email() {
    # echo "Subject: Network Connection Alert" | cat - $LOG_FILE | sendmail $EMAIL
    echo "Network Connection Alert: Connection to ${SERVER} is unreachable for ${MAX_FAIURES} times." 
    ring_bell 5
}

# Function to log status
log_status() {
    echo "$(date +'%Y-%m-%dT%H:%M:%S%:z') - $1" >> $LOG_FILE
}

# Monitor network connectivity in an infinite loop
while true; do
    # Ping the external server
    if ping -c 1 $SERVER > /dev/null 2>&1; then
        # If ping is successful, reset failure counter and log success
        FAILURE_COUNT=0
        log_status "Network is up. Connectivity to $SERVER is successful."
        # ring_bell 2
    else
        # If ping fails, increment failure counter and log failure
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        log_status "Network is down. Unable to reach $SERVER."
        ring_bell 3

        # If failure count exceeds the maximum allowed, send email notification
        if [ $FAILURE_COUNT -ge $MAX_FAILURES ]; then
            log_status "Failed to reach $SERVER for $MAX_FAILURES consecutive attempts. Sending email notification."
            send_email
            FAILURE_COUNT=0  # Reset failure count after sending the email
        fi
    fi

    # Wait before checking again
    sleep $PING_INTERVAL
done
