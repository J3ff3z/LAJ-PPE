#!/bin/bash

mkdir -p dossiertextespropres

fichier="$1"
dossiertest="./dossiertextespropres"
numerotation=1

signes="[+*#__--]"

for fichier in dumps-text/*;
do
    read -r url < "$fichier"
    texte=$(cat "$fichier" | grep -viE "^\s*$signes|$signes.*$signes|BUTTON|IFRAME|Search|settings[[:space:]]+icon|share[[:space:]]+icon|Reklama|logo|Resources|Home|Menu|Strona[[:space:]]+główna|go!|^[-— =+]+$")
    texte=$(echo "$texte" | sed -E '
        s|https?://[^[:space:]]+||g
        s|(^\|[[:space:]])[a-zA-Z0-9-]+(\.[a-z0-9]+)+||g
        s|[A-Za-z0-9._]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}||g
        s|\+?[1-9][0-9]{1,3}([[:space:].-]?[0-9]){6,12}||g
        ')
    echo "$texte"> "$dossiertest/lien-$numerotation.txt"
    sleep 1
    ((numerotation++))
done