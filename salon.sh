#!/bin/bash

# Connect to the salon database
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\\n~~~~~ MY SALON ~~~~~\\n"
echo "Welcome to My Salon, how can I help you?"

# Function to display services and handle invalid inputs
SHOW_SERVICES() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Prompt user for a service
SHOW_SERVICES
read SERVICE_ID_SELECTED

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

# If service doesn't exist, prompt again
while [[ -z $SERVICE_NAME ]]
do
  echo -e "\\nI could not find that service. What would you like today?"
  SHOW_SERVICES
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
done

# Get customer phone number
echo -e "\\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if the customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

# If customer doesn't exist, get their name
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

# Ask for appointment time
echo -e "\\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Insert appointment into the database
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirm appointment
echo -e "\\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
