#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"
RAND=$((1 + $RANDOM % 1000))

# Main guessing function
USER_GUESSED() {
  GUESS=$1
  GUESSES=$2
  RAND=$3
  USER_ID=$4

  if [[ $GUESS == $RAND ]]; then
    INSERT_GAME="$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES)")"
    echo "You guessed it in $GUESSES tries. The secret number was $RAND. Nice job!"
  else
    # Increment number of guesses
    ((GUESSES++))
    if [[ ! $GUESS =~ [0-9*] ]]; then
      echo "That is not an integer, guess again:"
      read GUESS
      USER_GUESSED $GUESS $GUESSES $RAND $USER_ID
    elif [[ $GUESS -gt $RAND ]]; then
      echo "It's lower than that, guess again:"
      read GUESS
      USER_GUESSED $GUESS $GUESSES $RAND $USER_ID
    else
      echo "It's higher than that, guess again:"
      read GUESS
      USER_GUESSED $GUESS $GUESSES $RAND $USER_ID
    fi
  fi
}

# Entry point
echo "Enter your username:"
read NAME
USER_ID="$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")"
# Check if user exists in the database
if [[ -z $USER_ID ]]; then
  echo "Welcome, $NAME! It looks like this is your first time here."
  INSERT_USER="$($PSQL "INSERT INTO users(name) VALUES('$NAME')")"
  USER_ID="$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")"
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  USER_GUESSED $GUESS 1 $RAND $USER_ID
  # Existing user, get record of games played
else
  GAMES_RESPONSE="$($PSQL "SELECT COUNT(*), MIN(guesses) FROM games WHERE user_id = $USER_ID")"
  IFS="|" read GAMES BEST < <(echo $GAMES_RESPONSE)
  echo "Welcome back, $NAME! You have played $GAMES games, and your best game took $BEST guesses."
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  USER_GUESSED $GUESS 1 $RAND $USER_ID
fi
