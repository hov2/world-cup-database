#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
 
# reset tables
echo $($PSQL "truncate games, teams")

# read file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # if row is not header
  if [[ $YEAR != year ]]
  then
    # get team_ids for winning and losing teams
    WINNER_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
    OPPONENT_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")

    # if winning_team_id not found, insert team and print result
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) values('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted winner into teams, $WINNER"
      fi
      # get new winning_team_id
      WINNER_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
    fi

    # if opponent_team_id not found, insert team and print result
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) values('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted opponent into teams, $OPPONENT"
      fi
      # get new opponent_team_id
      OPPONENT_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")
    fi

    # insert games and print result
    INSERT_GAME_RESULT=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted into games, $YEAR $ROUND $WINNER $OPPONENT"
      fi
  fi
done
