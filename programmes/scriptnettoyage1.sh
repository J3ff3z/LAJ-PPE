#!/bin/bash

mkdir -p dossiertextespropres

fichier="$1"
dossiertest="./dossiertextespropres"
numerotation=1

signes="[+*#__--]"

for fichier in $(ls dumps-text | sort -t- -k2 -n);
do
    echo
    grep -viE "^\s*$signes|$signes.*$signes|BUTTON|IFRAME|Search|settings[[:space:]]+icon|share[[:space:]]+icon|Refresh|Reklama|logo|Resources|Home|Menu|Strona[[:space:]]+główna|go!|^[-— =+]+$" "dumps-text/$fichier" \
    | sed -E '
        s|https?://[^[:space:]]+||g;
        s|[a-zA-Z0-9-]+(\.[a-zA-Z0-9]+)+||g;
        s|[A-Za-z0-9._]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}||g;
        s|\+?[1-9][0-9]{1,3}([[:space:].-]?[0-9]){6,12}||g;
        s|#?oEmbed[[:space:]]*\(JSON\)||g;
        s|oEmbed[[:space:]]*\(XML\)||g;
        s|#alternate[[:space:]]*alternate||g;
        s|#alternate||g;
        s|#?JSON||g;
        s|\[INS\:[[:space:]]*\:INS\]||g;
        s|#RSS[[:space:]]*RSS||g;
        s|#[[:space:]]*RSS||g;
        s|\[tr\?.*\]||g;
        s|(pre-meta)||g;
        s|\[[[:space:]]*\]||g;
        s|\[X\]||g;
    '> "$dossiertest/propre-$numerotation.txt"
    ((numerotation++))
done