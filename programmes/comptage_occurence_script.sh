#!/bin/bash

if [ $# -eq 0 ]; 
then 
    echo "indiquez un fichier" 
    exit 1 
fi 

fichier="$1"

resu=$(grep -oiE '\bgrzech(u|owi|em|y|om|ami|ach|ów)?\b|\b(péché)s?\b' "$fichier" | wc -l)
echo "Occurence du mot : $resu"


#.//ce_script dossiertextespropres/NOMFICHIERPROPRE(propre-1.txt etc)