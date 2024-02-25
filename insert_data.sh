#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

#rimuovo tutti i dati dalle tabelle
echo -e "\n$($PSQL " TRUNCATE TABLE games, teams ")\n"

# Do not change code above this line. Use the PSQL variable above to query your database.
# aggiungo le squadre alla relazione teams
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do  
  # scarto la prima riga del file, la quale non contiene informazioni utilizi ma solo il nome delle colonne (attributi)
  if [[ $YEAR != year ]]
  then

    # verifico se la squadra winner già esiste
    TEAM_WINNER_EXIST=$($PSQL " SELECT COUNT(*) FROM teams WHERE name = '$WINNER' ")

    # se non eisiste lo inserisco nella relazione
    if [[ $TEAM_WINNER_EXIST == 0 ]]
    then

      # inserisco la squadra nella relazione teams
      INSERT_TEAM=$($PSQL " INSERT INTO teams (name) VALUES ('$WINNER') ")
      #DEBUG
      echo inserisco, $WINNER, risultato inserimento: $INSERT_TEAM

    fi

    # verifico se la squadra opponent già esiste
    TEAM_OPPONENT_EXIST=$($PSQL " SELECT COUNT(*) FROM teams WHERE name = '$OPPONENT' ")

    # se non eisiste lo inserisco nella relazione
    if [[ $TEAM_OPPONENT_EXIST == 0 ]]
    then

      # inserisco la squadra nella relazione teams
      INSERT_TEAM=$($PSQL " INSERT INTO teams (name) VALUES ('$OPPONENT') ")
      # DEBUG
      echo inserisco, $OPPONENT, risultato inserimento: $INSERT_TEAM

    fi

  fi

done

# DEBUG-verifico il numero di squadre inserite
echo -e "\nnumero di squadre inserite: $($PSQL " SELECT COUNT(*) FROM teams ")\n"

# aggiungo i dati alla relazione games
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  # scarto la prima riga del file, la quale non contiene informazioni utilizi ma solo il nome delle colonne (attributi)
  if [[ $YEAR != year ]]
  then

    # recupero l'id della squadra vincitrice
    WINNER_ID=$($PSQL " SELECT team_id FROM teams WHERE name = '$WINNER' ")
  
    # recupero l'id della squadra avversaria
    OPPONENT_ID=$($PSQL " SELECT team_id FROM teams WHERE name = '$OPPONENT' ")

    # inserisco il game nella relazione games
    INSERT_GAMES=$($PSQL " INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS) ")
    # DEBUG
    echo risultato inserimento: $INSERT_GAMES

  fi

done

# DEBUG-verifico il numero di game inseriti
echo -e "\nnumero di squadre inserite: $($PSQL " SELECT COUNT(*) FROM games ")\n"
