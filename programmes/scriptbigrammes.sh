#!/bin/bash

if [ $# -eq 0 ]; then
    echo "pas de fichier indiqué"
    exit 1
fi

mkdir -p dossierbigrammes

fichier="$1"
nombre="${2:-25}"
nom=$(basename "$fichier" .txt)
dossierfinal="dossierbigrammes/${nom}-bigrammes.txt"


cat "$fichier" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]' | grep -oE '\w+' > dossierbigrammes/premier.txt
tail -n +2 dossierbigrammes/premier.txt > dossierbigrammes/deuxieme.txt
paste dossierbigrammes/premier.txt dossierbigrammes/deuxieme.txt | sed '$d' | sort | uniq -c | sort -nr | head -n "$nombre" > "$dossierfinal"

rm dossierbigrammes/premier.txt dossierbigrammes/deuxieme.txt

echo "$dossierfinal"
