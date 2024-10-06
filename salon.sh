#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

# create main menu function
MAIN_MENU() {
  # if a message argument was passed display it
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  echo "$($PSQL "SELECT * FROM services ORDER BY service_id")" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # let customer choose service by entering the service_id
  read SERVICE_ID_SELECTED

  # if service choice isn't a number or if the chosen service doesn't exist 
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ || -z $($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED") ]]
  then
    # recurse to main menu with prompt
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # attempt to get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if it doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # insert into customers table
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi
    echo -e "\nWhat time would you like your cut, $(echo $CUSTOMER_NAME | sed -E 's/^ //')"
    read SERVICE_TIME

    # insert into appointments
    INSERT_INTO_APPOINTMENTS_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    # final message and exit
    echo -e "\nI have put you down for a cut at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ //')."
  fi
}

# run main menu function with no arguments
MAIN_MENU

