#!/usr/bin/bash

if [ $# -eq 0 ];
then
    echo "indiquez une langue"
    exit 1
fi

LANGUE="$1"
CHEMIN="PALS/"

source venv/bin/activate

if [ "$LANGUE" == "fr" ]; then
    MOT_CIBLE="[Pp]échés?"
elif [ "$LANGUE" == "pl" ]; then
    MOT_CIBLE="[Gg]rzech(u|owi|em|y|om|ami|ach|ów)?"
elif [ "$LANGUE" == "jp" ]; then
    MOT_CIBLE="大?罪"
fi

python3 "programmes/tokenizer_$LANGUE.py"
python3 "programmes/cooccurrents.py" "$CHEMIN/dump-$LANGUE.txt" --target "$MOT_CIBLE" --match-mode regex > "$CHEMIN"dump-"$LANGUE".tsv 2> /dev/null
python3 "programmes/cooccurrents.py" "$CHEMIN/contextes-$LANGUE.txt" --target "$MOT_CIBLE" --match-mode regex > "$CHEMIN"contextes-"$LANGUE".tsv 2> /dev/null

deactivate
