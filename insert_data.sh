#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Drop all of the tables in the database

echo "$($PSQL "DROP TABLE teams,games")"

# Creating the teams (team_id serial PK, name varchar UNIQUE)
echo "$($PSQL "CREATE TABLE teams(team_id SERIAL PRIMARY KEY, name varchar UNIQUE NOT NULL)")"

# Creating the games (game_id serial PK, year INT, round VARCHAR)
echo "$($PSQL "CREATE TABLE games(game_id SERIAL PRIMARY KEY, year INT NOT NULL, round VARCHAR NOT NULL, winner_id SERIAL REFERENCES teams(team_id) NOT NULL, opponent_id SERIAL REFERENCES teams(team_id) NOT NULL, winner_goals INT NOT NULL, opponent_goals INT NOT NULL)")"

# Inserting Team function
insert_team(){

  # Checking if the current winner is present in the database
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$1'")

    # In case the major_id was not present in the database, add It there
    if [[ -z $TEAM_ID ]]
    then
      # Add the team to the database
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$1')")
      # Printing that I've added the new team
      if [[ $INSERT_TEAM_RESULT='INSERT 0 1' ]]
      then
        # Print a custom message
        echo "Just added a new team to the database : "$1
      fi
    fi
}

# Inserting the game function
insert_game(){
  # Add row to the database
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($1,'$2',$3,$4,$5,$6)")
  if [[ $INSERT_GAME_RESULT='INSERT 0 1' ]]
      then
        # Print a custom message
        echo "Just added a new game to the database"
      fi
}

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
# Inserting winners
  if [[ $YEAR != 'year' ]]
  then
    # Check if the winner is present in the database and take his id
    insert_team "$WINNER"

    # Check if the opponent is present in the database and take his id
    insert_team "$OPPONENT"

    # Add the game to the database
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    insert_game "$YEAR" "$ROUND" "$WINNER_ID" "$OPPONENT_ID" "$WINNER_GOALS" "$OPPONENT_GOALS"
  fi
done

# Adding the games to the database


