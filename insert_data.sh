#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear tables
echo "$($PSQL "TRUNCATE TABLE games, teams")"

# Iterate games.csv and enter details into postgres
while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    echo "$($PSQL "INSERT INTO teams(name) VALUES('$WINNER'), ('$OPPONENT') ON CONFLICT DO NOTHING")"
    echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', (SELECT team_id from teams WHERE name = '$WINNER' ), (SELECT team_id from teams WHERE name = '$OPPONENT'), $WINNER_GOALS, $OPPONENT_GOALS)")"
  fi
done < games.csv
