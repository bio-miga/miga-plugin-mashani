#!/bin/bash

if [[ $SCRIPT == "distances.bash" ]] ; then
  echo Script: $SCRIPT
  echo Plugin: MashANI
  
  function miga-make_empty_ani_db {
    local DB=$1
    echo "CREATE TABLE IF NOT EXISTS ani( seq1 varchar(256)," \
      " seq2 varchar(256), ani float, sd float, n int, omega int );" \
      | sqlite3 $DB
    echo "CREATE TABLE IF NOT EXISTS rbm( seq1 varchar(256)," \
      " seq2 varchar(256), id1 int, id2 int, id float, evalue float," \
      " bitscore float );" \
      | sqlite3 $DB
    echo "CREATE TABLE IF NOT EXISTS regions( seq varchar(256), " \
      " id int, source varchar(256), \`start\` int, \`end\` int );" \
      | sqlite3 $DB
  }
  
  function miga-ani {
    local F1=$1 # File 1 (qry)
    local F2=$2 # File 2 (sbj)
    local TH=$3 # Threads (cores)
    local DB=$4 # Database (sqlite3)
    local N1=$(miga-ds_name $F1)
    local N2=$(miga-ds_name $F2)
    # Initialize (if needed)
    [[ -s $DB ]] || miga-make_empty_ani_db $DB
    # Run MashANI
    local ANI=($(mashcgi -q $F1 -s $F2 -o /dev/stdout))
    # Save and return results
    if [[ -n ${ANI[1]} ]] ; then
      echo "INSERT INTO ani VALUES( '$N1', '$N2', ${ANI[1]}, 0.0," \
        " ${ANI[2]}, ${ANI[3]} );" | sqlite3 $DB
      echo ${ANI[1]}
    else
      echo "0"
    fi
  }
  
fi

