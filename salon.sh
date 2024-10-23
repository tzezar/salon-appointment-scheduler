#!/bin/bash

# Welcome message
echo "~~~~~ MY SALON ~~~~~"
echo "Welcome to My Salon, how can I help you?"

# Function to display available services
display_services() {
    echo "Available services:"
    psql --username=freecodecamp --dbname=salon -t -A -c "SELECT service_id, name FROM services;" | awk -F '|' '{print $1") "$2}'
}

# Function to get a valid service ID from the user
get_service_id() {
    while true; do
        display_services
        read -p "Please select a service by entering the service ID: " SERVICE_ID_SELECTED
        
        # Check if the service ID is valid in the database
        SERVICE_COUNT=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT COUNT(*) FROM services WHERE service_id = $SERVICE_ID_SELECTED;" | xargs)

        if [[ "$SERVICE_COUNT" == "1" ]]; then
            break  # Valid service ID, exit loop
        else
            echo "I could not find that service. Please try again."
        fi
    done
}

# Call the function to get a valid service ID
get_service_id

# Prompt for customer phone number
read -p "What's your phone number? " CUSTOMER_PHONE

# Check if the customer exists
CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

# If the customer is new, prompt for their name
if [ -z "$CUSTOMER_NAME" ]; then
    read -p "I don't have a record for that phone number, what's your name? " CUSTOMER_NAME
    # Insert new customer into the database
    psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
else
    echo "Welcome back, $CUSTOMER_NAME!"
fi

# Prompt for appointment time
read -p "What time would you like your service, $CUSTOMER_NAME? " SERVICE_TIME

# Insert the appointment into the database
psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ((SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'), $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Output confirmation message
SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
