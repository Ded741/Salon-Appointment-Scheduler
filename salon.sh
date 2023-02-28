#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon ~~~~~"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  echo -e "\nAvailable Services:"
  SERVICES=$($PSQL "SELECT name, service_id FROM services")
  echo "$SERVICES" | while read SERVICE_NAME BAR SERVICE_ID
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo -e "\nWhich one would you like to book?"
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ [1-3] ]]
  then
    MAIN_MENU "Please enter a valid service."
  else
    if [[ -z $SERVICE_ID_SELECTED ]]
    then
      MAIN_MENU "Please enter a valid service."
    else
      echo -e "\nEnter your phone number"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME

        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
      
      echo -e "\nWhat time would you like your service, $(echo $CUSTOMER_NAME | sed 's/ *//g')?"
      read SERVICE_TIME

      CUSTOMER_ID_1=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID_1', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
    
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
      echo "$SERVICE_NAME" | while read NAME
      do 
        echo -e "\nI have put you down for a $NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ *//g')."
      done
    fi
  fi
}
