#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games;")

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip first row
  if [[ "$YEAR" != 'year' ]]
  then
    # Getting Teams ID
    TEAM_ID_W=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    TEAM_ID_O=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # If Winner team is not found in teams table
    if [[ -z $TEAM_ID_W ]]
    then
      # Insert winner team value into the table
      INSERT_ID_W=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      # Confirmation of success
      if [[ $INSERT_ID_W == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $WINNER"
      fi
    fi
    # If Opponent team is not found in teams table
    if [[ -z $TEAM_ID_O ]]
    then
      # Insert winner team value into the table
      INSERT_ID_O=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      # Confirmation of success
      if [[ $INSERT_ID_O == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $OPPONENT"
      fi
    fi  
  fi

done

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip first row
  if [[ "$YEAR" != 'year' ]]
  then
    # Getting the ID from the Winner or Opposing team
    TEAM_ID_W=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    TEAM_ID_O=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Adding IDs to the games table
    INSERT_GAME_R=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_ID_W, $TEAM_ID_O, $WINNER_GOALS, $OPPONENT_GOALS)")

    if [[ $INSERT_GAME_R == "INSERT 0 1" ]]
    then
      echo "Inserted into games, $YEAR | $ROUND - ($TEAM_ID_W)$WINNER Vs ($TEAM_ID_O)$OPPONENT | $WINNER_GOALS-$OPPONENT_GOALS"
    fi
  fi
done

