#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  echo "Welcome to My Salon, how can I help you?" 
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME BAR
  do
      echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  # find service
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # if service doesn't exist
  if [[ -z $SERVICE_ID_SELECTED ]]
  then
    # show list again
    echo -e "\nI could not find that service. What would you like today?"
    echo "$SERVICES" | while read SERVICE_ID BAR NAME BAR
    do
        echo "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED
  fi

  # get customer phone
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # find customer by phone
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    # if not customer
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # insert a new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
  # find appointment
  APPOINTMENT_ID=$($PSQL "SELECT appointment_id FROM appointments WHERE customer_id = $CUSTOMER_ID")
  if [[ -z $APPOINTMENT_ID ]]
  then
    # if now appointment yet
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME
    # insert a new appointment
    INSERT_SERVICE_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
