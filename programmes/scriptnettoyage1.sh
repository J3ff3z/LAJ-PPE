#!/bin/bash

if [ $# -eq 0 ]; 
then 
    echo "indiquez un fichier" 
    exit 1 
fi 

fichier="$1"

mkdir -p dossiertextespropres

dossiertest="dossiertextespropres"
numerotation=1

signes="[+\*#_\-]"


echo
grep -viE "^\s*$signes|$signes.*$signes|BUTTON|IFRAME|Search|settings[[:space:]]+icon|share[[:space:]]+icon|Refresh|Reklama|logo|Resources|Home|Menu|Strona[[:space:]]+główna|go!|^[-— =+]+$" "$fichier" \
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
'> "$dossiertest/$(basename $fichier)"

echo  "$dossiertest/$(basename $fichier)"
