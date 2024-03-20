#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams;")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    #get team_id of winner
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
    #team not found
    if [[ -z $TEAM_ID ]]
    then 
      #insert new team
      INSERT_TEAM_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")"
      if [[ INSERT_TEAM_RESULT="INSERT 0 1" ]]
      then 
        echo "Inserted into teams, $WINNER"
      fi
    fi
    #get team_id of opponent
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")
    #team not found
    if [[ -z $TEAM_ID ]]
    then 
      #insert new team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      if [[ INSERT_TEAM_RESULT="INSERT 0 1" ]]
      then 
        echo "Inserted into teams, $OPPONENT"
      fi
    fi
    
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")
    INSERT_GAME_RESULT="$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', '$WINNER_ID', '$OPPONENT_ID', $WINNER_GOALS, $OPPONENT_GOALS);")"
    if [[ INSERT_GAME_RESULT="INSERT 0 1" ]]
    then 
      echo "Inserted $YEAR game - $WINNER vs $OPPONENT - SCORE: $WINNER_GOALS - $OPPONENT_GOALS"
    fi
  fi
done
