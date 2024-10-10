#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Display message if no argument is passed
if [[ -z $1 ]]; then
  echo Please provide an element as an argument.
else
  # Find element
  if [[ $1 =~ [0-9]+ ]]; then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
  elif [[ ${#1} -le 2 ]]; then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")
  else
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
  fi

  # Could not find element
  if [[ -z $ATOMIC_NUMBER ]]; then
    echo I could not find that element in the database.
  else
    # echo $ATOMIC_NUMBER
    QUERY_RESULT="$($PSQL "SELECT symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER;")"
    IFS="|" read SYMBOL NAME MASS MELTING BOILING TYPE < <(echo $QUERY_RESULT)
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  fi
fi
